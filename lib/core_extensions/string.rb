# We use Hash#inspect in ExpressTemplates::Markup::Wrapper to reproduce arguments
# to helpers in the Rails view.
#
# Hash#inspect calls #inspect on values and keys.  This allows us to
# place the resulting string into the view code with a simple substitution
# or concatenation.
#
# In special cases, however, we might want the argument or one of its keys
# or values to be the result of evaluating of a ruby expression in the view
# that does not itself return a String.  The result of #inspect
# is normally a quoted and escaped string which would evaluate to a string
# in the view.  What we want is a simple string of code.  Here we provide
# a method that overrides #inspect in the strings eigenclass to strip off
# enclosing quotes or unwanted escapes.  It shouldn't bother anybody and
# it keeps us from doing messy things elsewhere for now.
class String
  def to_view_code
    class << self
      def inspect
        super.gsub(/^"(.*)"$/,'\1')
      end
    end
    return self
  end
end