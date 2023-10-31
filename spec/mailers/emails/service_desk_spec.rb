# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe Emails::ServiceDesk, feature_category: :service_desk do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include EmailHelpers

  include_context 'gitlab email notification'
  include_context 'with service desk mailer'

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project, description: 'Some **issue** description') }
  let_it_be(:email) { 'someone@gitlab.com' }
  let_it_be(:expected_unsubscribe_url) { unsubscribe_sent_notification_url('b7721fc7e8419911a8bea145236a0519') }
  let_it_be(:credential) { create(:service_desk_custom_email_credential, project: project) }
  let_it_be(:verification) { create(:service_desk_custom_email_verification, project: project) }
  let_it_be(:service_desk_setting) { create(:service_desk_setting, project: project, custom_email: 'user@example.com') }

  let(:template) { double(content: template_content) }

  before_all do
    issue.issue_email_participants.create!(email: email)
  end

  shared_examples 'a service desk notification email' do |attachments_count|
    it 'builds the email correctly' do
      aggregate_failures do
        is_expected.to have_referable_subject(issue, include_project: false, reply: reply_in_subject)

        expect(subject.attachments.count).to eq(attachments_count.to_i)

        expect(subject.content_type).to include('multipart/alternative')

        expect(subject.parts[0].body.to_s).to include(expected_text)
        expect(subject.parts[0].content_type).to include('text/plain')

        expect(subject.parts[1].body.to_s).to include(expected_html)
        expect(subject.parts[1].content_type).to include('text/html')
      end
    end
  end

  shared_examples 'a service desk notification email with template content' do |template_key, attachments_count|
    before do
      expect(Gitlab::Template::ServiceDeskTemplate).to receive(:find)
        .with(template_key, issue.project)
        .and_return(template)
    end

    it 'builds the email correctly' do
      aggregate_failures do
        is_expected.to have_referable_subject(issue, include_project: false, reply: reply_in_subject)
        is_expected.to have_body_text(expected_template_html)

        expect(subject.attachments.count).to eq(attachments_count.to_i)

        if attachments_count.to_i > 0
          # Envelope for emails with attachments is always multipart/mixed
          expect(subject.content_type).to include('multipart/mixed')
          # Template content only renders a html body, so ensure its content type is set accordingly
          expect(subject.parts.first.content_type).to include('text/html')
        else
          expect(subject.content_type).to include('text/html')
        end
      end
    end
  end

  shared_examples 'read template from repository' do |template_key|
    let(:template_content) { 'custom text' }
    let(:issue) { create(:issue, project: project) }

    before do
      issue.issue_email_participants.create!(email: email)
    end

    context 'when a template is in the repository' do
      let(:project) { create(:project, :custom_repo, files: { ".gitlab/service_desk_templates/#{template_key}.md" => template_content }) }

      it 'uses the text template from the template' do
        is_expected.to have_body_text(template_content)
      end
    end

    context 'when the service_desk_templates directory does not contain correct template' do
      let(:project) { create(:project, :custom_repo, files: { ".gitlab/service_desk_templates/another_file.md" => template_content }) }

      it 'uses the default template' do
        expect(subject.text_part.to_s).to include(expected_text)
        expect(subject.html_part.to_s).to include(expected_html)
      end
    end

    context 'when the service_desk_templates directory does not exist' do
      let(:project) { create(:project, :custom_repo, files: { "other_directory/another_file.md" => template_content }) }

      it 'uses the default template' do
        expect(subject.text_part.to_s).to include(expected_text)
        expect(subject.html_part.to_s).to include(expected_html)
      end
    end

    context 'when the project does not have a repo' do
      let(:project) { create(:project) }

      it 'uses the default template' do
        expect(subject.text_part.to_s).to include(expected_text)
        expect(subject.html_part.to_s).to include(expected_html)
      end
    end
  end

  shared_examples 'a custom email verification process email' do
    it 'contains custom email and project in subject' do
      expect(subject.subject).to include(service_desk_setting.custom_email)
      expect(subject.subject).to include(service_desk_setting.project.name)
    end
  end

  shared_examples 'a custom email verification process notification email' do
    it 'has correct recipient' do
      expect(subject.to).to eq(['owner@example.com'])
    end

    it 'contains custom email and project in body' do
      is_expected.to have_body_text(service_desk_setting.custom_email)
      is_expected.to have_body_text(service_desk_setting.project.name)
    end
  end

  shared_examples 'a custom email verification process result email with error' do |error_identifier, expected_text|
    context "when having #{error_identifier} error" do
      before do
        service_desk_setting.custom_email_verification.error = error_identifier
      end

      it 'contains correct error message headline in text part' do
        # look for text part because we can ignore HTML tags then
        expect(subject.text_part.body).to match(expected_text)
      end
    end
  end

  describe '.service_desk_thank_you_email' do
    let_it_be(:reply_in_subject) { true }
    let_it_be(:expected_text) do
      "Thank you for your support request! We are tracking your request as ticket #{issue.to_reference}, and will respond as soon as we can."
    end

    let_it_be(:expected_html) { expected_text }

    subject { ServiceEmailClass.service_desk_thank_you_email(issue.id) }

    it_behaves_like 'a service desk notification email'
    it_behaves_like 'read template from repository', 'thank_you'

    context 'handling template markdown' do
      context 'with a simple text' do
        let(:template_content) { 'thank you, **your new issue** has been created.' }
        let(:expected_template_html) { 'thank you, <strong>your new issue</strong> has been created.' }

        it_behaves_like 'a service desk notification email with template content', 'thank_you'
      end

      context 'with an issue id, issue path and unsubscribe url placeholders' do
        let(:template_content) do
          'thank you, **your new issue:** %{ISSUE_ID}, path: %{ISSUE_PATH}' \
            '[Unsubscribe](%{UNSUBSCRIBE_URL})'
        end

        let(:expected_template_html) do
          "<p dir=\"auto\">thank you, <strong>your new issue:</strong> ##{issue.iid}, path: #{project.full_path}##{issue.iid}" \
            "<a href=\"#{expected_unsubscribe_url}\">Unsubscribe</a></p>"
        end

        it_behaves_like 'a service desk notification email with template content', 'thank_you'
      end

      context 'with header and footer placeholders' do
        let(:template_content) do
          '%{SYSTEM_HEADER}' \
            'thank you, **your new issue** has been created.' \
            '%{SYSTEM_FOOTER}'
        end

        it_behaves_like 'appearance header and footer enabled'
        it_behaves_like 'appearance header and footer not enabled'
      end

      context 'with an issue id placeholder with whitespace' do
        let(:template_content) { 'thank you, **your new issue:** %{  ISSUE_ID}' }
        let(:expected_template_html) { "thank you, <strong>your new issue:</strong> ##{issue.iid}" }

        it_behaves_like 'a service desk notification email with template content', 'thank_you'
      end

      context 'with unexpected placeholder' do
        let(:template_content) { 'thank you, **your new issue:** %{this is issue}' }
        let(:expected_template_html) { "thank you, <strong>your new issue:</strong> %{this is issue}" }

        it_behaves_like 'a service desk notification email with template content', 'thank_you'
      end

      context 'when issue description placeholder is used' do
        let(:template_content) { 'thank you, your new issue has been created. %{ISSUE_DESCRIPTION}' }
        let(:expected_template_html) { "<p dir=\"auto\">thank you, your new issue has been created. </p>#{issue.description_html}" }

        it_behaves_like 'a service desk notification email with template content', 'thank_you'

        context 'when GitLab-specific-reference is in description' do
          let(:full_issue_reference) { "#{issue.project.full_path}#{issue.to_reference}" }
          let(:other_issue) { create(:issue, project: project, description: full_issue_reference) }

          let(:template_content) { '%{ISSUE_DESCRIPTION}' }
          let(:expected_template_html) { "<p data-sourcepos=\"1:1-1:22\" dir=\"auto\">#{full_issue_reference}</p>" }

          subject { ServiceEmailClass.service_desk_thank_you_email(other_issue.id) }

          before do
            expect(Gitlab::Template::ServiceDeskTemplate).to receive(:find)
              .with('thank_you', other_issue.project)
              .and_return(template)

            other_issue.issue_email_participants.create!(email: email)
          end

          it 'does not render GitLab-specific-reference links with title attribute' do
            is_expected.to have_body_text(expected_template_html)
          end
        end
      end

      context 'when issue url placeholder is used' do
        let(:full_issue_url) { issue_url(issue) }
        let(:template_content) { 'thank you, your new issue has been created. %{ISSUE_URL}' }
        let(:expected_template_html) do
          "<p dir=\"auto\">thank you, your new issue has been created. " \
            "<a href=\"#{full_issue_url}\">#{full_issue_url}</a></p>"
        end

        it_behaves_like 'a service desk notification email with template content', 'thank_you'

        context 'when it is used in markdown format' do
          let(:template_content) { 'thank you, your new issue has been created. [%{ISSUE_PATH}](%{ISSUE_URL})' }
          let(:issue_path) { "#{project.full_path}##{issue.iid}" }
          let(:expected_template_html) do
            "<p dir=\"auto\">thank you, your new issue has been created. " \
              "<a href=\"#{full_issue_url}\">#{issue_path}</a></p>"
          end

          it_behaves_like 'a service desk notification email with template content', 'thank_you'
        end
      end
    end
  end

  describe '.service_desk_new_note_email' do
    let_it_be(:reply_in_subject) { false }
    let_it_be(:expected_text) { 'My **note**' }
    let_it_be(:expected_html) { 'My <strong>note</strong>' }
    let_it_be(:note) { create(:note_on_issue, noteable: issue, project: project, note: expected_text) }

    subject { ServiceEmailClass.service_desk_new_note_email(issue.id, note.id, email) }

    it_behaves_like 'a service desk notification email'
    it_behaves_like 'read template from repository', 'new_note'

    context 'with template' do
      context 'with a simple text' do
        let(:template_content) { 'thank you, **new note on issue** has been created.' }
        let(:expected_template_html) { 'thank you, <strong>new note on issue</strong> has been created.' }

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'with an issue id, issue path, note and unsubscribe url placeholders' do
        let(:template_content) do
          'thank you, **new note on issue:** %{ISSUE_ID}, path: %{ISSUE_PATH}: %{NOTE_TEXT}' \
            '[Unsubscribe](%{UNSUBSCRIBE_URL})'
        end

        let(:expected_template_html) do
          "<p dir=\"auto\">thank you, <strong>new note on issue:</strong> ##{issue.iid}, path: #{project.full_path}##{issue.iid}: #{expected_html}" \
            "<a href=\"#{expected_unsubscribe_url}\">Unsubscribe</a></p>"
        end

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'with header and footer placeholders' do
        let(:template_content) do
          '%{SYSTEM_HEADER}' \
            'thank you, **your new issue** has been created.' \
            '%{SYSTEM_FOOTER}'
        end

        it_behaves_like 'appearance header and footer enabled'
        it_behaves_like 'appearance header and footer not enabled'
      end

      context 'with an issue id placeholder with whitespace' do
        let(:template_content) { 'thank you, **new note on issue:** %{  ISSUE_ID}: %{ NOTE_TEXT  }' }
        let(:expected_template_html) { "thank you, <strong>new note on issue:</strong> ##{issue.iid}: #{expected_html}" }

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'with unexpected placeholder' do
        let(:template_content) { 'thank you, **new note on issue:** %{this is issue}' }
        let(:expected_template_html) { "thank you, <strong>new note on issue:</strong> %{this is issue}" }

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'with all-user reference in a an external author comment' do
        let_it_be(:note) { create(:note_on_issue, noteable: issue, project: project, note: "Hey @all, just a ping", author: User.support_bot) }

        let(:template_content) { 'some text %{ NOTE_TEXT  }' }

        context 'when `disable_all_mention` is disabled' do
          let(:expected_template_html) { 'Hey , just a ping' }

          before do
            stub_feature_flags(disable_all_mention: false)
          end

          it_behaves_like 'a service desk notification email with template content', 'new_note'
        end

        context 'when `disable_all_mention` is enabled' do
          let(:expected_template_html) { 'Hey @all, just a ping' }

          before do
            stub_feature_flags(disable_all_mention: true)
          end

          it_behaves_like 'a service desk notification email with template content', 'new_note'
        end
      end
    end

    # handle email without and with template in this context to reduce code duplication
    context 'with upload link in the note' do
      let_it_be(:secret) { 'e90decf88d8f96fe9e1389afc2e4a91f' }
      let_it_be(:filename) { 'test.jpg' }
      let_it_be(:path) { "#{secret}/#{filename}" }
      let_it_be(:upload_path) { "/uploads/#{path}" }
      let_it_be(:template_content) { 'some text %{ NOTE_TEXT  }' }
      let_it_be(:expected_text) { "a new comment with [#{filename}](#{upload_path})" }
      let_it_be(:expected_html) { "a new comment with <strong>#{filename}</strong>" }
      let_it_be(:note) { create(:note_on_issue, noteable: issue, project: project, note: expected_text) }
      let!(:upload) { create(:upload, :issuable_upload, :with_file, model: note.project, path: path, secret: secret) }

      context 'when total uploads size is more than 10mb' do
        before do
          allow_next_instance_of(FileUploader) do |instance|
            allow(instance).to receive(:size).and_return(10.1.megabytes)
          end
        end

        let_it_be(:expected_html) { %(a new comment with <a href="#{project.web_url}#{upload_path}" data-canonical-src="#{upload_path}" data-link="true" class="gfm">#{filename}</a>) }
        let_it_be(:expected_template_html) { %(some text #{expected_html}) }

        it_behaves_like 'a service desk notification email'
        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'when total uploads size is less or equal 10mb' do
        context 'when it has only one upload' do
          before do
            allow_next_instance_of(FileUploader) do |instance|
              allow(instance).to receive(:size).and_return(10.megabytes)
              allow(instance).to receive(:read).and_return('')
            end
          end

          context 'when upload name is not changed in markdown' do
            let_it_be(:expected_template_html) { %(some text a new comment with <strong>#{filename}</strong>) }

            it_behaves_like 'a service desk notification email', 1
            it_behaves_like 'a service desk notification email with template content', 'new_note', 1
          end

          context 'when upload name is changed in markdown' do
            let_it_be(:upload_name_in_markdown) { 'Custom name' }
            let_it_be(:note) { create(:note_on_issue, noteable: issue, project: project, note: "a new comment with [#{upload_name_in_markdown}](#{upload_path})") }
            let_it_be(:expected_text) { %(a new comment with [#{upload_name_in_markdown}](#{upload_path})) }
            let_it_be(:expected_html) { %(a new comment with <strong>#{upload_name_in_markdown} (#{filename})</strong>) }
            let_it_be(:expected_template_html) { %(some text #{expected_html}) }

            it_behaves_like 'a service desk notification email', 1
            it_behaves_like 'a service desk notification email with template content', 'new_note', 1
          end
        end

        context 'when it has more than one upload' do
          let_it_be(:secret_1) { '17817c73e368777e6f743392e334fb8a' }
          let_it_be(:filename_1) { 'test1.jpg' }
          let_it_be(:path_1) { "#{secret_1}/#{filename_1}" }
          let_it_be(:upload_path_1) { "/uploads/#{path_1}" }
          let_it_be(:note) { create(:note_on_issue, noteable: issue, project: project, note: "a new comment with [#{filename}](#{upload_path}) [#{filename_1}](#{upload_path_1})") }

          context 'when all uploads processed correct' do
            before do
              allow_next_instance_of(FileUploader) do |instance|
                allow(instance).to receive(:size).and_return(5.megabytes)
                allow(instance).to receive(:read).and_return('')
              end
            end

            let_it_be(:upload_1) { create(:upload, :issuable_upload, :with_file, model: note.project, path: path_1, secret: secret_1) }

            let_it_be(:expected_html) { %(a new comment with <strong>#{filename}</strong> <strong>#{filename_1}</strong>) }
            let_it_be(:expected_template_html) { %(some text #{expected_html}) }

            it_behaves_like 'a service desk notification email', 2
            it_behaves_like 'a service desk notification email with template content', 'new_note', 2
          end

          context 'when not all uploads processed correct' do
            let_it_be(:expected_html) { %(a new comment with <strong>#{filename}</strong> <a href="#{project.web_url}#{upload_path_1}" data-canonical-src="#{upload_path_1}" data-link="true" class="gfm">#{filename_1}</a>) }
            let_it_be(:expected_template_html) { %(some text #{expected_html}) }

            it_behaves_like 'a service desk notification email', 1
            it_behaves_like 'a service desk notification email with template content', 'new_note', 1
          end
        end
      end

      context 'when UploaderFinder is raising error' do
        before do
          allow_next_instance_of(UploaderFinder) do |instance|
            allow(instance).to receive(:execute).and_raise(StandardError)
          end
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(StandardError, project_id: note.project_id)
        end

        let_it_be(:expected_template_html) { %(some text a new comment with <a href="#{project.web_url}#{upload_path}" data-canonical-src="#{upload_path}" data-link="true" class="gfm">#{filename}</a>) }

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end

      context 'when FileUploader is raising error' do
        before do
          allow_next_instance_of(FileUploader) do |instance|
            allow(instance).to receive(:read).and_raise(StandardError)
          end
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(StandardError, project_id: note.project_id)
        end

        let_it_be(:expected_template_html) { %(some text a new comment with <a href="#{project.web_url}#{upload_path}" data-canonical-src="#{upload_path}" data-link="true" class="gfm">#{filename}</a>) }

        it_behaves_like 'a service desk notification email with template content', 'new_note'
      end
    end
  end

  describe '.service_desk_custom_email_verification_email' do
    subject { Notify.service_desk_custom_email_verification_email(service_desk_setting) }

    it_behaves_like 'a custom email verification process email'

    it 'uses service bot name and custom email as sender' do
      expect_sender(User.support_bot, sender_email: service_desk_setting.custom_email)
    end

    it 'forcibly uses SMTP delivery method and has correct settings' do
      expect_service_desk_custom_email_delivery_options(service_desk_setting)
    end

    it 'uses verification email address as recipient' do
      expect(subject.to).to eq([service_desk_setting.custom_email_address_for_verification])
    end

    it 'contains verification token' do
      is_expected.to have_body_text("Verification token: #{verification.token}")
    end
  end

  describe '.service_desk_verification_triggered_email' do
    before do
      service_desk_setting.custom_email_verification.triggerer = user
    end

    subject { Notify.service_desk_verification_triggered_email(service_desk_setting, 'owner@example.com') }

    it_behaves_like 'an email sent from GitLab'
    it_behaves_like 'a custom email verification process email'
    it_behaves_like 'a custom email verification process notification email'

    it 'contains triggerer username' do
      is_expected.to have_body_text("@#{user.username}")
    end
  end

  describe '.service_desk_verification_result_email' do
    before do
      service_desk_setting.custom_email_verification.triggerer = user
    end

    subject { Notify.service_desk_verification_result_email(service_desk_setting, 'owner@example.com') }

    it_behaves_like 'an email sent from GitLab'
    it_behaves_like 'a custom email verification process email'
    it_behaves_like 'a custom email verification process notification email'
    it_behaves_like 'a custom email verification process result email with error', 'smtp_host_issue', 'SMTP host issue'
    it_behaves_like 'a custom email verification process result email with error', 'invalid_credentials', 'Invalid credentials'
    it_behaves_like 'a custom email verification process result email with error', 'mail_not_received_within_timeframe', 'Verification email not received within timeframe'
    it_behaves_like 'a custom email verification process result email with error', 'incorrect_from', 'Incorrect From header'
    it_behaves_like 'a custom email verification process result email with error', 'incorrect_token', 'Incorrect verification token'
  end
end
