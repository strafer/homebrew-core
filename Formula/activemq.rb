class Activemq < Formula
  desc "Apache ActiveMQ: powerful open source messaging server"
  homepage "https://activemq.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=/activemq/5.13.3/apache-activemq-5.13.3-bin.tar.gz"
  sha256 "6ac9e617195cb071cfd55556870dd3d2ef4a9078466e0e690277553e81635568"

  bottle :unneeded

  depends_on :java => "1.6+"

  def install
    rm_rf Dir["bin/linux-x86-*"]
    libexec.install Dir["*"]
    (bin/"activemq").write_env_script libexec/"bin/activemq", Language::Java.java_home_env("1.6+")
  end

  test do
    system "#{bin}/activemq", "browse", "-h"
  end
end
