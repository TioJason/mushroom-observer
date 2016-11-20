module Query::Modules::ActiveRecord
  attr_accessor :record

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def safe_find(id)
      find(id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find(id)
      record = QueryRecord.find(id)
      query = Query.deserialize(record.description)
      record.query = query
      query.record = record
      query.outer_id = record.outer_id
      QueryRecord.cleanup
      query
    end

    def lookup_and_save(*args)
      query = lookup(*args)
      query.record.save!
      query
    end

    def lookup(*args)
      query = Query.new(*args)
      record = get_record(query)
      record.query = query
      query.record = record
      query.outer_id = record.outer_id
      QueryRecord.cleanup
      query
    end

    def get_record(query)
      desc = query.serialize
      QueryRecord.find_by_description(desc) ||
      QueryRecord.new(
        description:  desc,
        updated_at:   Time.now,
        access_count: 0
      )
    end
  end

  def record
    @record ||= Query.get_record(self)
  end

  def id
    record.id
  end

  def save
    record.outer_id = outer_id
    record.save
  end

  def increment_access_count
    record.access_count += 1
  end
end
