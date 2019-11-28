# frozen_string_literal: true

module Exceptions
  
    class BadRequest < StandardError
      def status
        :bad_request
      end
    end
  
    class Unauthorized < StandardError
      def status
        :unauthorized
      end
    end
  
    class Forbidden < StandardError
      def status
        :forbidden
      end
    end
  
    class InternalServerError < StandardError
      def status
        :internal_server_error
      end
    end
  
    class PageOverRequest < BadRequest
        def message
            "Request Error - Page is over request !"
        end
    end

    class PageUnderRequest < BadRequest
        def message
            "Request Error - Page is starting from 1 !"
        end
    end

    class ParameterIsNotInteger < BadRequest
        def message
            "Request Error - Parameter is not Integer !"
        end
    end

    # class ProductNotFound < BadRequest
    # end
  end
  