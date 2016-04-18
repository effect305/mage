class ActiveRecord::Base
  def self.has_mage_steps(*steps)
    @@mage_steps = steps
    has_one :mage_step, class_name: 'Mage::MageStep', as: :object
    scope :mage_done, -> { joins(:mage_step).where(mage_steps: { step: :done }) }
    after_save :mage_after_save
    after_destroy { Mage::MageStep.where(object_id: self.id, object_type: self.model_name.name).try(:take).try(:destroy) }

    def self.mage_steps
      @@mage_steps
    end

    instance_eval do
      define_method :mage_step do
        Mage::MageStep.where(object_id: self.id, object_type: self.model_name.name)
            .try(:take).try(:step).try(:to_sym) || @@mage_steps.first
      end

      steps.each_with_index do |step, index|
        define_method "mage_step_#{step}?" do
          index <= (@@mage_steps.find_index(mage_step) || @@mage_steps.count)
        end
      end

      define_method :mage_after_save do
        if mage_step != :done
          mage_model = Mage::MageStep.where(object_id: id, object_type: model_name.name).try(:take) ||
              Mage::MageStep.create(object_id: id, object_type: model_name.name, step: mage_step)
          mage_model.update(step: (@@mage_steps[@@mage_steps.find_index(mage_step) + 1] || :done))
        end
      end

      private :mage_after_save

    end
  end
end
