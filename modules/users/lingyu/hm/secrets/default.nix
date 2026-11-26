{
  secrets = {
    nutstore = {
      user.rekeyFile = ./nutstore/user.age;
      pass.rekeyFile = ./nutstore/pass.age;
    };
    "123cloud" = {
      user.rekeyFile = ./123cloud/user.age;
      pass.rekeyFile = ./123cloud/pass.age;
    };
    cloudflare = {
      access_key_id.rekeyFile = ./cloudflare/access_key_id.age;
      secret_access_key.rekeyFile = ./cloudflare/secret_access_key.age;
      endpoint.rekeyFile = ./cloudflare/endpoint.age;
    };
    alibabacloud.oss = {
      access_key_id.rekeyFile = ./alibabacloud/oss/access_key_id.age;
      secret_access_key.rekeyFile = ./alibabacloud/oss/secret_access_key.age;
    };
    deepseek.apiKey.pi.rekeyFile = ./deepseek/apiKey/pi.age;
    moonshot.cn.apiKey.pi.rekeyFile = ./moonshot/cn/apiKey/pi.age;
    zai.cn.apiKey.pi.rekeyFile = ./zai/cn/apiKey/pi.age;
  };
}
