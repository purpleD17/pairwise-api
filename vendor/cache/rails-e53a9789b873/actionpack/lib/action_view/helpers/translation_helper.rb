require 'action_view/helpers/tag_helper'

module ActionView
  module Helpers
    module TranslationHelper
      # Delegates to I18n#translate but also performs two additional functions. First, it'll catch MissingTranslationData exceptions
      # and turn them into inline spans that contains the missing key, such that you can see in a view what is missing where.
      #
      # Second, it'll scope the key by the current partial if the key starts with a period. So if you call translate(".foo") from the
      # people/index.html.erb template, you'll actually be calling I18n.translate("people.index.foo"). This makes it less repetitive
      # to translate many keys within the same partials and gives you a simple framework for scoping them consistently. If you don't
      # prepend the key with a period, nothing is converted.
      def translate(keys, options = {})
        if multiple_keys = keys.is_a?(Array)
          ActiveSupport::Deprecation.warn "Giving an array to translate is deprecated, please give a symbol or a string instead", caller
        else
          keys = Array.wrap(keys)
        end

        options[:raise] = true

        options = options.dup
        has_default = options.has_key?(:default)
        remaining_defaults = Array(options.delete(:default)).compact
        if has_default && !remaining_defaults.first.kind_of?(Symbol)
          options[:default] = remaining_defaults
        end

        translations = keys.map do |key|
          qualified_key = scope_key_by_partial(key)
          if html_safe_translation_key?(qualified_key)
            html_safe_options = options.dup

            if ActionView::Base.xss_safe?
              reserved_keys = defined?(I18n::RESERVED_KEYS) ? I18n::RESERVED_KEYS : I18n::Backend::Base::RESERVED_KEYS
              options.except(:raise, *reserved_keys).each do |name, value|
                html_safe_options[name] = ERB::Util.html_escape(value.to_s)
              end
            end

            html_safe_options[:default] = MISSING_TRANSLATION unless html_safe_options[:default].blank?

            translation = I18n.translate(qualified_key, html_safe_options)

            if translation.equal?(MISSING_TRANSLATION)
              options[:default].first
            else
              translation.respond_to?(:html_safe) ? translation.html_safe : translation
            end
          else
            I18n.translate(qualified_key, options)
          end
        end

        if multiple_keys
          translations
        else
          translations.first
        end

      rescue I18n::MissingTranslationData => e
        if remaining_defaults.present?
          first_default = remaining_defaults.shift
          remaining_options = options.merge(:default => remaining_defaults)
          translate(first_default, remaining_options)
        else
          keys = I18n.send(:normalize_translation_keys, e.locale, e.key, e.options[:scope])
          content_tag('span', keys.join(', '), :class => 'translation_missing')
        end
      end
      alias :t :translate

      # Delegates to I18n.localize with no additional functionality.
      def localize(*args)
        I18n.localize(*args)
      end
      alias :l :localize


      private

        MISSING_TRANSLATION = Object.new
        private_constant :MISSING_TRANSLATION if RUBY_VERSION >= "1.9.3"

        def scope_key_by_partial(key)
          key = key.to_s

          if key.first == "."
            template.path_without_format_and_extension.gsub(%r{/_?}, ".") + key
          else
            key
          end
        end

        def html_safe_translation_key?(key)
          key =~ /(\b|_|\.)html$/
        end

    end
  end
end
