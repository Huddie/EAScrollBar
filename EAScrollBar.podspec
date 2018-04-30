
Pod::Spec.new do |s|
s.name             = 'EAScrollBar'
s.version          = '0.1.10'
s.summary          = 'A simple scrollbar'

s.description      = <<-DESC
This scroll bar allows for quick jumping
DESC

s.homepage         = 'https://github.com/Huddie/EAScrollBar'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Ehud Adler' => 'easports96@gmail.com' }
s.source           = { :git => 'https://github.com/Huddie/EAScrollBar.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'
s.source_files = 'EAScrollBar/EAScrollBar/*.swift'

end
