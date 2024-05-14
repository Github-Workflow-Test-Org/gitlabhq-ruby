# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing::SidekiqServerMiddleware, :clean_gitlab_redis_queues, feature_category: :scalability do
  let(:middleware) { described_class.new }
  let(:worker) { worker_class.new }
  let(:location) { '0/D525E3A8' }
  let(:wal_locations) { { Gitlab::Database::MAIN_DATABASE_NAME.to_s => location } }
  let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", 'wal_locations' => wal_locations } }
  let(:any_caught_up) { Gitlab::Database::LoadBalancing::LoadBalancer::ANY_CAUGHT_UP }
  let(:all_caught_up) { Gitlab::Database::LoadBalancing::LoadBalancer::ALL_CAUGHT_UP }
  let(:none_caught_up) { Gitlab::Database::LoadBalancing::LoadBalancer::NONE_CAUGHT_UP }

  before do
    skip_default_enabled_yaml_check

    replication_lag!(false)
    Gitlab::Database::LoadBalancing::Session.clear_session

    stub_const("#{described_class.name}::REPLICA_WAIT_SLEEP_SECONDS", 0.0)
  end

  after do
    Gitlab::Database::LoadBalancing::Session.clear_session
  end

  describe '#call' do
    shared_context 'data consistency worker class' do |data_consistency, feature_flag|
      let(:worker_class) do
        Class.new do
          def self.name
            'TestDataConsistencyWorker'
          end

          include ApplicationWorker

          data_consistency data_consistency, feature_flag: feature_flag

          def perform(*args); end
        end
      end

      before do
        stub_const('TestDataConsistencyWorker', worker_class)
      end
    end

    shared_examples_for 'load balancing strategy' do |strategy|
      it "sets load balancing strategy to #{strategy}" do
        run_middleware do
          expect(job['load_balancing_strategy']).to eq(strategy)
        end
      end
    end

    shared_examples_for 'stick to the primary' do |expected_strategy|
      it 'sticks to the primary' do
        run_middleware do
          expect(Gitlab::Database::LoadBalancing::Session.current.use_primary?).to be_truthy
        end
      end

      include_examples 'load balancing strategy', expected_strategy
    end

    shared_examples_for 'replica is up to date' do |expected_strategy|
      it 'does not stick to the primary', :aggregate_failures do
        expect(ActiveRecord::Base.load_balancer)
          .to receive(:select_up_to_date_host)
          .with(location)
          .and_return(any_caught_up)

        run_middleware do
          expect(Gitlab::Database::LoadBalancing::Session.current.use_primary?).not_to be_truthy
        end
      end

      include_examples 'load balancing strategy', expected_strategy
    end

    shared_examples_for 'sticks based on data consistency' do
      context 'when database wal location is set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e', 'wal_locations' => wal_locations } }

        before do
          Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
            allow(lb)
              .to receive(:select_up_to_date_host)
              .with(location)
              .and_return(any_caught_up)
          end
        end

        it_behaves_like 'replica is up to date', 'replica'
      end

      context 'when deduplication wal location is set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e', 'dedup_wal_locations' => wal_locations } }

        before do
          allow(ActiveRecord::Base.load_balancer)
            .to receive(:select_up_to_date_host)
            .with(wal_locations[:main])
            .and_return(any_caught_up)
        end

        it_behaves_like 'replica is up to date', 'replica'
      end

      context 'when database location is not set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e' } }

        include_examples 'stick to the primary', 'primary_no_wal'
      end
    end

    shared_examples_for 'essential sleep' do
      context 'when WAL locations are blank', :freeze_time do
        let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", "wal_locations" => {}, "created_at" => Time.current.to_f - (described_class::REPLICA_WAIT_SLEEP_SECONDS + 0.2) } }

        it 'does not sleep' do
          expect(middleware).not_to receive(:sleep)

          run_middleware
        end
      end

      context 'when WAL locations are present', :freeze_time do
        let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", 'wal_locations' => wal_locations, "created_at" => Time.current.to_f - elapsed_time } }

        context 'when delay interval has not elapsed' do
          let(:elapsed_time) { described_class::REPLICA_WAIT_SLEEP_SECONDS + 0.2 }

          context 'when replica is up to date' do
            before do
              Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
                allow(lb).to receive(:select_up_to_date_host).and_return(any_caught_up)
              end
            end

            it 'does not sleep' do
              expect(middleware).not_to receive(:sleep)

              run_middleware
            end
          end

          context 'when replica is not up to date' do
            before do
              Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
                allow(lb).to receive(:select_up_to_date_host).and_return(none_caught_up, any_caught_up)
              end
            end

            it 'sleeps until the minimum delay is reached' do
              expect(middleware).to receive(:sleep).with(described_class::REPLICA_WAIT_SLEEP_SECONDS)

              run_middleware
            end
          end

          context 'when replica is never not up to date' do
            before do
              Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
                allow(lb).to receive(:select_up_to_date_host).and_return(none_caught_up, none_caught_up)
              end
            end

            it 'sleeps until the maximum delay is reached' do
              expect(middleware).to receive(:sleep).exactly(3).times.with(described_class::REPLICA_WAIT_SLEEP_SECONDS)

              run_middleware
            end
          end
        end
      end
    end

    context 'when worker class does not include WorkerAttributes' do
      let(:worker) { ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.new }

      include_examples 'stick to the primary', 'primary'
    end

    context 'when job contains wrapped worker class' do
      let(:worker) { ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.new }
      let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", 'wal_locations' => wal_locations, 'wrapped' => 'ActionMailer::MailDeliveryJob' } }

      it 'uses wrapped job if available' do
        expect(middleware).to receive(:select_load_balancing_strategy).with(ActionMailer::MailDeliveryJob, job).and_call_original

        run_middleware
      end
    end

    context 'when worker data consistency is :always' do
      include_context 'data consistency worker class', :always, :load_balancing_for_test_data_consistency_worker

      include_examples 'stick to the primary', 'primary'

      context 'when delay interval has not elapsed', :freeze_time do
        let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", 'wal_locations' => wal_locations, "created_at" => Time.current.to_f - elapsed_time } }
        let(:elapsed_time) { described_class::REPLICA_WAIT_SLEEP_SECONDS + 0.2 }

        it 'does not sleep' do
          expect(middleware).not_to receive(:sleep)

          run_middleware
        end
      end
    end

    context 'when worker data consistency is :delayed' do
      include_context 'data consistency worker class', :delayed, :load_balancing_for_test_data_consistency_worker

      include_examples 'sticks based on data consistency'
      include_examples 'essential sleep'

      context 'when replica is not up to date' do
        before do
          replication_lag!(true)
        end

        around do |example|
          with_sidekiq_server_middleware do |chain|
            chain.add described_class
            Sidekiq::Testing.disable! { example.run }
          end
        end

        context 'when job is executed first' do
          it 'raises an error and retries', :aggregate_failures do
            expect do
              Gitlab::SidekiqSharding::Validator.allow_unrouted_sidekiq_calls { process_job(job) }
            end.to raise_error(Sidekiq::JobRetry::Skip)

            job_for_retry = Gitlab::SidekiqSharding::Validator.allow_unrouted_sidekiq_calls { Sidekiq::RetrySet.new.first }
            expect(job_for_retry['error_class']).to eq('Gitlab::Database::LoadBalancing::SidekiqServerMiddleware::JobReplicaNotUpToDate')
          end

          include_examples 'load balancing strategy', 'retry'
        end

        context 'when job is retried' do
          let(:job) { { "retry" => 3, "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e", 'wal_locations' => wal_locations, 'retry_count' => 0 } }

          context 'and replica still lagging behind' do
            include_examples 'stick to the primary', 'primary'
          end

          context 'and replica is now up-to-date' do
            before do
              replication_lag!(false)
            end

            include_examples 'replica is up to date', 'replica_retried'
          end
        end
      end
    end

    context 'when worker data consistency is :sticky' do
      include_context 'data consistency worker class', :sticky, :load_balancing_for_test_data_consistency_worker

      include_examples 'sticks based on data consistency'
      include_examples 'essential sleep'

      context 'when replica is not up to date' do
        before do
          Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
            allow(lb).to receive(:select_up_to_date_host).and_return(none_caught_up)
          end
        end

        include_examples 'stick to the primary', 'primary'
      end
    end
  end

  describe '#databases_in_sync?' do
    it 'treats load balancers without WAL entries as in sync' do
      expect(middleware.send(:databases_in_sync?, {}))
        .to eq(true)
    end

    it 'returns true when all load balancers are in sync for some replicas' do
      locations = {}

      Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
        locations[lb.name] = 'foo'

        expect(lb)
          .to receive(:select_up_to_date_host)
          .with('foo')
          .and_return(any_caught_up)
      end

      expect(middleware.send(:databases_in_sync?, locations))
        .to eq(true)
    end

    it 'returns true when all load balancers are in sync for all replicas' do
      locations = {}

      Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
        locations[lb.name] = 'foo'

        expect(lb)
          .to receive(:select_up_to_date_host)
          .with('foo')
          .and_return(all_caught_up)
      end

      expect(middleware.send(:databases_in_sync?, locations))
        .to eq(true)
    end

    it 'returns false when the load balancers are not in sync' do
      locations = {}

      Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
        locations[lb.name] = 'foo'

        allow(lb)
          .to receive(:select_up_to_date_host)
          .with('foo')
          .and_return(none_caught_up)
      end

      expect(middleware.send(:databases_in_sync?, locations))
        .to eq(false)
    end

    context 'when locations have string keys' do
      it 'returns false when the load balancers are not in sync' do
        locations = {}

        Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
          locations[lb.name.to_s] = 'foo'

          allow(lb)
            .to receive(:select_up_to_date_host)
                  .with('foo')
                  .and_return(none_caught_up)
        end

        expect(middleware.send(:databases_in_sync?, locations))
          .to eq(false)
      end
    end
  end

  def process_job(job)
    Sidekiq::JobRetry.new(Sidekiq).local(worker_class, job.to_json, 'default') do
      worker_class.process_job(job)
    end
  end

  def run_middleware
    middleware.call(worker, job, double(:queue)) { yield if block_given? }
  rescue described_class::JobReplicaNotUpToDate
    # we silence errors here that cause the job to retry
  end

  def replication_lag!(exists)
    caught_up = exists ? none_caught_up : all_caught_up
    Gitlab::Database::LoadBalancing.each_load_balancer do |lb|
      allow(lb).to receive(:select_up_to_date_host).and_return(caught_up)
    end
  end
end
