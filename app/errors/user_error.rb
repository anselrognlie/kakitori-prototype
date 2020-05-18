class UserError < StandardError; end

class UserNotFoundError < UserError; end

class UserRepositoryError < UserError; end