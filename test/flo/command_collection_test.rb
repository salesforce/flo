# Copyright (c) 2015, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require_relative '../minitest_helper'
require 'flo/command_collection'

module Flo
  class CommandCollectionTest < Flo::UnitTest

    def subject
      @subject ||= Flo::CommandCollection.new
    end

    def test_a_single_symbol_can_be_used_as_a_storage_key
      command = Object.new
      subject[:command_name] = command
      assert_same command, subject[:command_name]
    end

    def test_an_array_of_symbols_can_be_used_as_a_storage_key
      command = Object.new
      subject[:name, :spaced, :command] = command
      assert_same command, subject[:name, :spaced, :command]
    end

    def test_properly_selects_correct_command
      command1 = Object.new
      command2 = Object.new
      subject[:name, :spaced, :command1] = command1
      subject[:name, :spaced, :command2] = command2

      assert_same command1, subject[:name, :spaced, :command1]
      assert_same command2, subject[:name, :spaced, :command2]
    end

    def test_selecting_a_command_that_doesnt_exist_raises_error
      assert_raises(Flo::CommandNotDefinedError) do
        subject[:undefined_command]
      end
    end

  end
end