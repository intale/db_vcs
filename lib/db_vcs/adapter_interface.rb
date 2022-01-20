# frozen_string_literal: true

module DbVcs
  module AdapterInterface
    def config
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def connection
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def db_exists?(db_name)
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def copy_database(to_db, from_db)
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def create_database(db_name)
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def list_databases
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end

    def drop_by_dbname(db_name)
      raise NotImplementedError, "You have to implement this method in adapter's class"
    end
  end
end
