# frozen_string_literal: true

module QA
  module Page
    module Project
      module Registry
        class Show < QA::Page::Base
          view 'app/assets/javascripts/packages_and_registries/container_registry/explorer/components/list_page/image_list_row.vue' do
            element :details_link
          end

          view 'app/assets/javascripts/packages_and_registries/container_registry/explorer/components/details_page/tags_list_row.vue' do
            element :additional_actions
            element :single_delete_button
            element :name
          end

          def has_registry_repository?(name)
            find_element(:details_link, text: name)
          end

          def click_on_image(name)
            click_element(:details_link, text: name)
          end

          def has_tag?(tag_name)
            has_element?(:name, text: tag_name)
          end

          def has_no_tag?(tag_name)
            has_no_element?(:name, text: tag_name)
          end

          def click_delete
            click_element(:additional_actions)
            click_element(:single_delete_button)
            find_button('Delete').click
          end
        end
      end
    end
  end
end
