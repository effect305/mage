require 'mage/version'

module Mage
  class WizardRendered < Exception
  end

  class MageStep < ActiveRecord::Base
    belongs_to :object, polymorphic: true
  end
end

class ActiveRecord::Base
  def self.has_mage_steps(*steps)
    @@mage_steps = steps
    after_save :mage_after_save
    after_destroy { Mage::MageStep.where(object_id: self.id, object_type: self.model_name.name).try(:take).try(:destroy) }

    define_method :mage_steps do
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

class ActionController::Base
  rescue_from Mage::WizardRendered, with: :mage_return

  def render_mage(object, options = {})
    puts "#{object}"
    unless object.mage_step == :done
      if request.method == 'GET'
        if options[:show_step] && params[:step].blank?
          mage_redirect(object, options[:show_step])
        else
          if flash["#{object.model_name.name.downcase}_errors"]
            flash["#{object.model_name.name.downcase}_errors"].each do |attribute, errors|
              errors.each { |error| object.errors[attribute] << error }
            end
          end
          render "#{params[:controller]}/steps/#{object.mage_step}"
        end
      else
        mage_redirect(object, options[:show_step])
      end
      raise Mage::WizardRendered.new
    end
  end

  def mage_redirect(object, show_step = false)
    flash["#{object.model_name.name.downcase}_errors"] = object.errors.messages
    path = object.new_record? ? :new_polymorphic_path : :edit_polymorphic_path
    redirect_to send(path, object, step: (object.mage_step if show_step))
  end

  def mage_return
  end

  private :mage_return, :mage_redirect
end

