
# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# inhibit_all_warnings!

# 部分不支持 macCatalyst 的 pod，可用以下方案处理
# https://github.com/fermoya/CatalystPodSupport

target 'App' do
    platform :ios, '15.0'

#    pod 'AMap3DMap-NO-IDFA'             # 高德地图
#    pod 'AXRatingView'                  # 打星评分控件
#    pod 'AliyunOSSiOS'                  # 阿里云文件存储
#    pod 'Bugly'                         # 腾讯崩溃收集
#    pod 'CollectionViewCenteredFlowLayout' # CollectionView 居中对齐
#    pod 'FLEX', :configurations => 'Debug' # 开发辅助工具集
#    pod 'GRDB.swift'                    # SQLite 数据库
#    pod 'GTSDK'                         # 推送: 个推
#    pod 'QingNiuSDK'                    # 七牛云存储
    pod 'SDWebImage'                    # 网络图片加载
#    pod 'UICollectionViewLeftAlignedLayout' # CollectionView 左对齐
#    pod 'WechatOpenSDK'                 # 微信 SDK

    pod 'RFKit', :subspecs => [
        'Category/NSDate',
        'Category/NSDateFormatter',
        'Category/NSFileManager',
        'Category/NSLayoutConstraint',
        'Category/UIScrollView+RFScrolling',
        'Category/UITableView',
    ]
    pod 'RFAlpha', :subspecs => [
        'RFBlockSelectorPerform',
        'RFButton',
        'RFCallbackControl',
        'RFContainerView',
        'RFDrawImage',
        'RFImageCropper',
        'RFNavigationController',
        'RFRefreshControl',
        'RFSwizzle',
        'RFSynthesize',
        'RFTabController',
        'RFTableViewPullToFetchPlugin',
        'RFTimer',
        'RFViewApperance/RFLine',
        'RFWindow',
    ]
    pod 'RFAPI', :subspecs => ['JSONModel']
    pod 'RFInitializing'
    pod 'RFDelegateChain', :subspecs => [
        'UICollectionViewDelegateFlowLayout',
        'UICollectionViewDataSource',
        'UITextFieldDelegate',
        'UITextViewDelegate',
    ]
    pod 'RFKeyboard'
    pod 'RFMessageManager', :subspecs => ['SVProgressHUD']
    pod 'RFSegue', :subspecs => ['Async']

    # 子依赖，隐藏警告
    pod 'SVProgressHUD', :inhibit_warnings => true
end

post_install do |pi|
    # 临时修正 deployment target 不支持的问题，并且让 Pod 跟随 App 支持的版本进行编译
    # https://github.com/CocoaPods/CocoaPods/issues/7314#issuecomment-422283045
    fix_deployment_target(pi)
end

def fix_deployment_target(pod_installer)
    if !pod_installer
        return
    end
    puts "Make the pods deployment target version the same as our target"
    
    project = pod_installer.pods_project
    deploymentMap = {}
    project.build_configurations.each do |config|
        deploymentMap[config.name] = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    end
    # p deploymentMap
    
    project.targets.each do |t|
        puts "  #{t.name}"
        t.build_configurations.each do |config|
            oldTarget = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
            newTarget = deploymentMap[config.name]
            if oldTarget == newTarget
                next
            end
            puts "    #{config.name} deployment target: #{oldTarget} => #{newTarget}"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = newTarget
        end
    end
end
