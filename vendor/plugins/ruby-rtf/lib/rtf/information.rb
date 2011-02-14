#!/usr/bin/env ruby

require 'stringio'
# require 'parsedate'

module RTF
   # This class represents an information group for a RTF document.
   class Information
      # Attribute accessor.
      attr_reader :title, :author, :company, :created, :comments

      # Attribute mutator.
      attr_writer :title, :author, :company, :comments


      # This is the constructor for the Information class.
      #
      # ==== Parameters
      # title::     A string containing the document title information. Defaults
      #             to nil.
      # author::    A string containing the document author information.
      #             Defaults to nil.
      # company::   A string containing the company name information. Defaults
      #             to nil.
      # comments::  A string containing the information comments. Defaults to
      #             nil to indicate no comments.
      # creation::  A Time object or a String that can be parsed into a Time
      #             object (using ParseDate) indicating the document creation
      #             date and time. Defaults to nil to indicate the current
      #             date and time.
      #
      # ==== Exceptions
      # RTFError::  Generated whenever invalid creation date/time details are
      #             specified.
      def initialize(title=nil, author=nil, company=nil, comments=nil, creation=nil)
         @title       = title
         @author      = author
         @company     = company
         @comments    = comments
         self.created = (creation == nil ? Time.new : creation)
      end

      # This method provides the created attribute mutator for the Information
      # class.
      #
      # ==== Parameters
      # setting::  The new creation date/time setting for the object. This
      #            should be either a Time object or a string containing
      #            date/time details that can be parsed into a Time object
      #            (using the parsedate method).
      #
      # ==== Exceptions
      # RTFError::  Generated whenever invalid creation date/time details are
      #             specified.
      def created=(setting)
         if setting.instance_of?(Time)
            @created = setting
         else
            datetime = Time.parse(setting.to_s)
            # datetime = ParseDate::parsedate(setting.to_s)
            if datetime == nil
               RTFError.fire("Invalid document creation date/time information "\
                             "specified.")
            end
            @created = datetime
            # @created = Time.local(datetime[0], datetime[1], datetime[2],
            #                       datetime[3], datetime[4], datetime[5])
         end
      end

      # This method creates a textual description for an Information object.
      #
      # ==== Parameters
      # indent::  The number of spaces to prefix to the lines generated by the
      #           method. Defaults to zero.
      def to_s(indent=0)
         prefix = indent > 0 ? ' ' * indent : ''
         text   = StringIO.new

         text << "#{prefix}Information"
         text << "\n#{prefix}   Title:    #{@title}" if @title != nil
         text << "\n#{prefix}   Author:   #{@author}" if @author != nil
         text << "\n#{prefix}   Company:  #{@company}" if @company != nil
         text << "\n#{prefix}   Comments: #{@comments}" if @comments != nil
         text << "\n#{prefix}   Created:  #{@created}" if @created != nil

         text.string
      end

      # This method generates the RTF text for an Information object.
      #
      # ==== Parameters
      # indent::  The number of spaces to prefix to the lines generated by the
      #           method. Defaults to zero.
      def to_rtf(indent=0)
         prefix = indent > 0 ? ' ' * indent : ''
         text   = StringIO.new

         text << "#{prefix}{\\info"
         text << "\n#{prefix}{\\title #{@title}}" if @title != nil
         text << "\n#{prefix}{\\author #{@author}}" if @author != nil
         text << "\n#{prefix}{\\company #{@company}}" if @company != nil
         text << "\n#{prefix}{\\doccomm #{@comments}}" if @comments != nil
         if @created != nil
            text << "\n#{prefix}{\\createim\\yr#{@created.year}"
            text << "\\mo#{@created.month}\\dy#{@created.day}"
            text << "\\hr#{@created.hour}\\min#{@created.min}}"
         end
         text << "\n#{prefix}}"

         text.string
      end
   end # End of the Information class.
end # End of the RTF module.
