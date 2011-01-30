module ApplicationHelper
  def flash_messages(key)
    if flash[key]
      haml_tag(:p, :class => key.to_s) do
        haml_concat(flash[key])
      end
    end
  end
end

