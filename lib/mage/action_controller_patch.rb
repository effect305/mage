module Mage
  class WizardRendered < Exception
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
          (flash["#{object.model_name.name.downcase}_errors"] || {}).each do |attribute, errors|
            errors.each { |error| object.errors[attribute] << error }
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
