class CapsuleCRM::Party < CapsuleCRM::Base
  include CapsuleCRM::History
  
  # nodoc
  def addresses
    return @addresses if @addresses
    data = raw_data['contacts'].try(:[], 'address')
    @addresses = CapsuleCRM::Address.init_many(self, data)
  end


  # nodoc
  def custom_fields
    return @custom_fields if @custom_fields
    path = self.class.get_path
    path = [path, '/', id, '/customfield'].join
    last_response = self.class.get(path)
    data = last_response['customFields'].try(:[], 'customField')
    @custom_fields = CapsuleCRM::CustomField.init_many(self, data)
  end

  def tags
    return @tags if @tags
    path = self.class.get_path
    path = [path, '/', id, '/tag'].join
    last_response = self.class.get(path)
    data = last_response['tags'].try(:[], 'tag')
    @tags = CapsuleCRM::Tag.init_many(self, data)
  end

  def tag_names
    tags.map(&:name)
  end

  # nodoc
  def emails
    return @emails if @emails
    data = raw_data['contacts'].try(:[], 'email')
    @emails = CapsuleCRM::Email.init_many(self, data)
  end


  # nodoc
  def phone_numbers
    return @phone_numbers if @phone_numbers
    data = raw_data['contacts'].try(:[], 'phone')
    @phone_numbers = CapsuleCRM::Phone.init_many(self, data)
  end

  # nodoc
  def websites
    return @websites if @websites
    data = raw_data['contacts'].try(:[], 'website')
    @websites = CapsuleCRM::Website.init_many(self, data)
  end

  def is?(kind)
    required_class = kind.to_s.camelize
    self.class.to_s.include? required_class
  end

  def tag(value)
    # unset tags so that if anyone were to request tags again, it
    # requests an update from the server.
    @tags = nil
    path = self.class.get_path
    tag = URI.escape(value.to_s)
    path = [path, id, 'tag', tag].join('/')
    req = self.class.post(path)
    req.response.code == ("201" || "200")
  end

  
  def untag(value)
    # unset tags so that if anyone were to request tags again, it
    # requests an update from the server.
    @tags = nil
    path = self.class.get_path
    tag = URI.escape(value.to_s)
    path = [path, id, 'tag', tag].join('/')
    req = self.class.delete(path)
    req.response.code == "200"
  end
  
  # nodoc
  def self.get_path
    '/api/party'
  end


  def self.find_all_by_email(email, options={})
    options[:email] = email
    find_all(options)
  end


  # nodoc
  def self.find_by_email(email)
    find_all_by_email(email, :limit => 1, :offset => 0).first
  end


  # nodoc
  def self.search(query, options={})
    options[:q] = query
    find_all(options)
  end

  def self.init_one(response)
    return CapsuleCRM::Person.init_one(response) if response['person']
    return CapsuleCRM::Organisation.init_one(response) if response['organisation']
    raise CapsuleCRM::RecordNotRecognised, "Could not recognise returned entity type: #{response}"
  end
end
