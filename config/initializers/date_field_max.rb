module DateFieldWithMaxYear
  # As per request date_field should only be 4 digits total
  
    def date_field(method, options = {})
      max_year = "9999-12-31"
      options[:max] ||= max_year
      super(method, options)
    end
  end
  
  ActionView::Helpers::FormBuilder.prepend(DateFieldWithMaxYear)
  