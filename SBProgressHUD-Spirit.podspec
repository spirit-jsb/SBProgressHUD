Pod::Spec.new do |s|

    s.name        = 'SBProgressHUD-Spirit'
    s.module_name  = 'SBProgressHUD'
    s.version     = '1.0.5'
    s.summary     = 'A lightweight and pure Swift implemented library for easy to use translucent HUD for iOS with indicators and/or labels.'
  
    s.description = <<-DESC
                         SBProgressHUD is a lightweight and pure Swift implemented library for easy to use translucent HUD for iOS with indicators and/or labels.
                         DESC
  
    s.homepage    = 'https://github.com/spirit-jsb/SBProgressHUD'
    
    s.license     = { :type => 'MIT', :file => 'LICENSE' }
    
    s.author      = { 'spirit-jsb' => 'sibo_jian_29903549@163.com' }
    
    s.swift_versions = ['5.0']
    
    s.ios.deployment_target = '11.0'
      
    s.source       = { :git => 'https://github.com/spirit-jsb/SBProgressHUD.git', :tag => s.version }
    s.source_files = ["Sources/**/*.swift"]
    
    s.requires_arc = true
  end
  
