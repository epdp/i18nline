module I18nline
  class Translation < ActiveRecord::Base
    after_save :update_caches
    attr_accessor :make_nil
    serialize :value
    serialize :interpolations, Array

    default_scope { self.scoped.order("created_at desc") }

    def self.not_translated(apply_this = "1")
      if apply_this.present?
        where("(value is null or value = '--- \n...\n')")
      else
        self.scoped
      end
    end

    def self.blank_value(apply_this = "1")
      if apply_this.present?
        #value is serialized so searching for empty is complicated:
        where("value like ?", "".to_yaml)
      else
        self.scoped
      end
    end

    def self.in_locale(locale)
      if locale.present?
        where("locale = ?", locale)
      else
        self.scoped
      end
    end

    def self.search_key(to_search)
      if to_search.present?
        # 'key' is a reserved word for Mysql, so we ask the adapter to scape it,
        # since scaping is different for each database
        scaped_key = connection.quote_column_name("key")
        where("#{scaped_key} like ?", "%#{to_search}%")
      else
        self.scoped
      end
    end

    def self.search_value(to_search)
      if to_search.present?
        where("value like ?", "%#{to_search}%")
      else
        self.scoped
      end
    end

    def update_caches
      TRANSLATION_STORE.reload!
    end
  end
end
