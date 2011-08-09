module Rawesomium::Rawesomium
  extend FFI::Library
  ffi_lib Rails.root.to_s + "/bin/libSaveImage.so"
  attach_function :SaveImage, [:string, :string, :string, :string], :bool
end