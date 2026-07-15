class Mactelnet < Formula
  desc "Telnet/console client for MikroTik RouterOS over Layer 2 (MAC-Telnet)"
  homepage "https://github.com/haakonnessjoen/MAC-Telnet"
  url "https://github.com/haakonnessjoen/MAC-Telnet/archive/refs/tags/v0.6.3.tar.gz"
  sha256 "1b685568bddfe8d41cf70242a8db98968154334647b2c98c389596604e3fc38a"
  license "GPL-2.0-or-later"

  head "https://github.com/haakonnessjoen/MAC-Telnet.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/gregsadetsky/homebrew-mactelnet/releases/download/mactelnet-0.6.3"
    sha256 arm64_tahoe:   "75c06d091b37d09460e0bc062841e1927702b8e2c17e628441d13290349f3f65"
    sha256 arm64_sequoia: "9feaabf9e43a66b6826d58848d69530a3e1debe4a036558555615daf1f9f4c14"
    sha256 x86_64_linux:  "dae398aad494aadd47dc022ebdb79af8a19fe5c1d83177a76c6e5a961e5680a0"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "openssl@3"

  def install
    # Upstream's install-exec-hook chowns mactelnetd.users to root, which is
    # impossible in a non-root Homebrew install; chmod 600 still applies.
    inreplace "config/Makefile.am", /^\s*chown root.*$\n/, ""

    system "./autogen.sh"
    system "./configure", "--disable-silent-rules",
                          "--sysconfdir=#{etc}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    # mactelnet/macping print version and usage on stderr
    assert_match version.to_s, shell_output("#{bin}/mactelnet -v 2>&1")
    assert_match "Usage", shell_output("#{bin}/mactelnet -h 2>&1", 1)
    assert_match "Usage", shell_output("#{bin}/macping 2>&1", 1)
    assert_predicate bin/"mndp", :executable?
  end
end
