module Main
  class Application < Jets::Application
    config.project_name = "worknet-job-posting"
    config.mode = "api"
    config.cors = %w[
      localhost
      *.carepartner.kr
      *.dev-carepartner.kr
      backend-staging-wemrofzktq-du.a.run.app
      backend-production-wemrofzktq-du.a.run.app
    ].join(",")
    config.retry_attempts = 0
    config.prewarm.enable = true # default is truec
    # config.prewarm.rate = '30 minutes' # default is '30 minutes'
    # config.prewarm.concurrency = 2 # default is 2
    # config.prewarm.public_ratio = 3 # default is 3

    # config.env_extra = 2 # can also set this with JETS_ENV_EXTRA
    # config.autoload_paths = []

    # config.asset_base_url = 'https://cloudfront.domain.com/assets' # example

    # config.function.timeout = 30 # defaults to 30
    # config.function.role = "arn:aws:iam::#{Jets.aws.account}:role/service-role/pre-created"
    # config.function.memory_size = 1536

    # config.api.endpoint_type = 'PRIVATE' # Default is 'EDGE' (https://docs.aws.amazon.com/apigateway/api-reference/link-relation/restapi-create/#endpointConfiguration)

    # config.function.environment = {
    #   global_app_key1: "global_app_value1",
    #   global_app_key2: "global_app_value2",
    # }
    config.default_iam_policy = [{
                                   action: ["logs:*"],
                                   effect: "Allow",
                                   resource: "*"
                                 },
                                 {
                                   action: %w[s3:Get* s3:List* s3:HeadBucket],
                                   resource: "*",
                                   effect: "Allow"
                                 },
                                 {
                                   action: %w[cloudformation:DescribeStacks cloudformation:DescribeStackResources],
                                   resource: "*",
                                   effect: "Allow"
                                 },
                                 {
                                   action: %w[ec2:CreateNetworkInterface ec2:DeleteNetworkInterface ec2:DescribeNetworkInterfaces ec2:DescribeVpcs ec2:DescribeSubnets ec2:DescribeSecurityGroups],
                                   resource: "*",
                                   effect: "Allow"
                                 },
                                 {
                                   action: ["lambda:*"],
                                   effect: "Allow",
                                   resource: "*"
                                 }]

    config.function.vpc_config = {
      security_group_ids: %w[sg-04daf636f3d105ed8],
      subnet_ids: %w[subnet-0f4fd9c32ac1837ae subnet-022ab46ae6d9ebb7e],
    }
    # config.function.ephemeral_storage = { size: 1536 }
    # The config.function settings to the CloudFormation Lambda Function properties.
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html
    # Underscored format can be used for keys to make it look more ruby-ish.

    # Assets settings
    # The config.assets.folders are folders within the public folder that will be set
    # to public-read on s3 and served directly. IE: public/assets public/images public/packs
    # config.assets.folders = %w[assets images packs]
    # config.assets.max_age = 3600 # when to expire assets
    # config.assets.cache_control = nil # IE: "public, max-age=3600" # override max_age for more fine-grain control.
    # config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path, defaults to the s3 bucket url
    #                                IE: https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1inlzkvujq8zb

    # config.api.endpoint_type = 'PRIVATE' # Default is 'EDGE' https://amzn.to/2r0Iu2L
    # config.api.authorization_type = "AWS_IAM" # default is 'NONE' https://amzn.to/2qZ7zLh

    # More info: http://rubyonjets.com/docs/routing/custom-domain/
    # config.domain.hosted_zone_name = "example.com"
    # us-west-2 REGIONAL endpoint - takes 2 minutes
    # config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445566:certificate/8d8919ce-a710-4050-976b-b33da991e123"
    # us-east-1 EDGE endpoint - takes 10-15 minutes
    # config.domain.cert_arn = "arn:aws:acm:us-east-1:112233445566:certificate/d68472ba-04f8-45ba-b9db-14f839d57123"
    # config.domain.endpoint_type = "EDGE"

    # By default logger needs to log to $stderr for CloudWatch to receive Lambda messages, but for
    # local testing environment you may want to log these messages to 'test.log' file to keep your
    # testing suite output readable.
    # config.logger = Jets::Logger.new($stderr)

    config.controllers.default_protect_from_forgery = false

    # 개발, 스테이징 환경 내, 알림톡 송수신 테스트 목적으로 사용하는 번호 화이트리스트
    # 예시) '["01037863607", "01050502020"]'
    PHONE_NUMBER_WHITELIST = ENV['PHONE_NUMBER_WHITELIST']
    PHONE_NUMBER_WHITELIST = PHONE_NUMBER_WHITELIST.present? ? JSON.parse(PHONE_NUMBER_WHITELIST) :
                               %w[01037863607 01025179362 01094659404 01066121746 01049195808 01091372316 01029685055 01051119300 01098651017 01057513286 01034308850 01057540629 01029465752 01047974098 01046781989]
    TEST_PHONE_NUMBER = ENV['TEST_PHONE_NUMBER'] || '01029685055'
    BEX_API_URL = ENV['BEX_API_URL']
    BIZMSG_PROFILE = ENV['KAKAO_BIZMSG_PROFILE']
    DEEP_LINK_SCHEME = "carepartner://app"
    BUSINESS_URL = if Jets.env.production?
                     "http://business.carepartner.kr"
                   elsif Jets.env.staging?
                     "http://business.dev-carepartner.kr"
                   else
                     "http://127.0.0.1"
                   end

    CAREPARTNER_URL = if Jets.env.production?
                        "http://www.carepartner.kr/"
                      elsif Jets.env.staging?
                        "http://www.dev-carepartner.kr/"
                      else
                        "http://127.0.0.1:3000/"
                      end

    HTTPS_CAREPARTNER_URL = if Jets.env.production?
                        "https://www.carepartner.kr/"
                      elsif Jets.env.staging?
                        "https://www.dev-carepartner.kr/"
                      else
                        "https://127.0.0.1:3000/"
                      end
  end

  HTTPS_BUSINESS_URL = if Jets.env.production?
                         "https://business.carepartner.kr"
                       elsif Jets.env.staging?
                         "https://business.dev-carepartner.kr"
                       else
                         "https://127.0.0.1"
                       end

  NEWSPAPER_JOB_QUEUE_URL = ENV['NEWSPAPER_JOB_QUEUE_URL']
  USER_PUSH_JOB_QUEUE_URL = ENV['USER_PUSH_JOB_QUEUE_URL']
end
