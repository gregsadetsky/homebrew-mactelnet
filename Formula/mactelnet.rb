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
    sha256 arm64_tahoe:   "3049a06e03aeec79c729c86a4f4ac4fa7ca642c9783a7782decd82e2cef7338d"
    sha256 arm64_sequoia: "eb424140b9f17ea7b9874ce549caf51d6725bff8df9b162f3e7824df7c6215cc"
    sha256 x86_64_linux:  "ce3c7da5a507b413d03b73f7d1068e1e4501c9d4206f8a29e6dea2c2281f4819"
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
