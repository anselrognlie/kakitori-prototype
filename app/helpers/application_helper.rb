module ApplicationHelper
  def utcdate_display(date)
    date.localtime.strftime('%c')
  end
end
