class TomcatNative < Formula
  desc "Lets Tomcat use some native resources for performance"
  homepage "https://tomcat.apache.org/native-doc/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-connectors/native/1.2.7/source/tomcat-native-1.2.7-src.tar.gz"
  mirror "https://archive.apache.org/dist/tomcat/tomcat-connectors/native/1.2.7/source/tomcat-native-1.2.7-src.tar.gz"
  sha256 "19e87bc6ea7f763bf9e6515f8c31d8e9bb3e0c1132b36769cdf32c6702723d25"

  bottle do
    cellar :any
    sha256 "812275f3fa01eb1bc064ffaa9cd61e2ce47cf1a9762fcfb4a45462bf34194733" => :el_capitan
    sha256 "09407bdbd9b8d4554a371ce656cae047892fc6c24184a2df810b7a00257d62bb" => :yosemite
    sha256 "909155412b0d56cf7ea124afa70e8241da72a88bf0a51c605cfc5f07a553959a" => :mavericks
  end

  option "with-apr", "Include APR support via Homebrew"

  depends_on "libtool" => :build
  depends_on "tomcat" => :recommended
  depends_on :java => "1.7+"
  depends_on "openssl"
  depends_on "apr" => :optional

  def install
    cd "native" do
      if build.with? "apr"
        apr_path = Formula["apr"].opt_prefix
      else
        apr_path = "#{MacOS.sdk_path}/usr"
      end
      system "./configure", "--prefix=#{prefix}",
                            "--with-apr=#{apr_path}",
                            "--with-java-home=#{ENV["JAVA_HOME"]}",
                            "--with-ssl=#{Formula["openssl"].opt_prefix}"

      # fixes occasional compiling issue: glibtool: compile: specify a tag with `--tag'
      args = ["LIBTOOL=glibtool --tag=CC"]
      # fixes a broken link in mountain lion's apr-1-config (it should be /XcodeDefault.xctoolchain/):
      # usr/local/opt/libtool/bin/glibtool: line 1125: /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc: No such file or directory
      args << "CC=#{ENV.cc}" if MacOS.version >= :mountain_lion
      system "make", *args
      system "make", "install"
    end
  end

  def caveats; <<-EOS.undent
    In order for tomcat's APR lifecycle listener to find this library, you'll
    need to add it to java.library.path. This can be done by adding this line
    to $CATALINA_HOME/bin/setenv.sh

      CATALINA_OPTS=\"$CATALINA_OPTS -Djava.library.path=#{lib}\"

    If $CATALINA_HOME/bin/setenv.sh doesn't exist, create it and make it executable.
    EOS
  end
end
