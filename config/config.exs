#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2022 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
import Config

config :junit_formatter,
       report_file: "results.xml"

config :plug, :validate_header_keys_during_test, true