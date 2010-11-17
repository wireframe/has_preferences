module HasPreferences
  module InstanceMethods
    private
    def convert_to_default_type(pref, value)
      type = self.class.read_inheritable_attribute(:default_preferences)[pref].class
      if type == TrueClass || type == FalseClass
        value == true || (value && value.to_i == 1)
      elsif type == Fixnum
        value.nil? ? 0 : value.to_i
      else
        value
      end
    end
  end
  module ClassMethods
    def has_preferences(prefs = {})
      prefs.symbolize_keys!
      serialize :preferences, Hash
      write_inheritable_attribute :default_preferences, prefs
      class_eval "def self.default_preferences; read_inheritable_attribute(:default_preferences); end"
      attr_accessible *prefs.keys

      prefs.each_pair do |pref, default|
        define_preference pref, default
      end
      include InstanceMethods
    end

    private
    def define_preference(pref, default)
      define_method(pref) do
        self.preferences ||= {}
        value = self.preferences[pref]
        if value.nil?
          self.class.read_inheritable_attribute(:default_preferences)[pref]
        else
          convert_to_default_type pref, value
        end
      end
      if default.is_a?(TrueClass) || default.is_a?(FalseClass)
        define_method("#{pref}?") do
          self.send(pref)
        end
      end

      attr_accessor "#{pref}_changed"
      define_method("#{pref}_changed?") do
        self.send("#{pref}_changed") || false
      end

      define_method("#{pref}=") do |value|
        self.preferences ||= {}
        original_value = self.send(pref)
        if value == default
          self.preferences.delete pref
        else
          self.preferences[pref] = value
        end
        self.send "#{pref}_changed=", (self.send(pref) != original_value)
      end
    end
  end
end

ActiveRecord::Base.send(:extend, HasPreferences::ClassMethods)
