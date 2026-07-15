class Mactelnet < Formula
  desc "Telnet/console client for MikroTik RouterOS over Layer 2 (MAC-Telnet)"
  homepage "https://github.com/haakonnessjoen/MAC-Telnet"
  url "https://github.com/haakonnessjoen/MAC-Telnet/archive/refs/tags/v0.6.3.tar.gz"
  sha256 "1b685568bddfe8d41cf70242a8db98968154334647b2c98c389596604e3fc38a"
  license "GPL-2.0-or-later"

  head "https://github.com/haakonnessjoen/MAC-Telnet.git", branch: "master"

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
    assert_match "Usage", shell_output("#{bin}/mactelnet -h 2>&1")
    assert_match "Usage", shell_output("#{bin}/macping 2>&1")
    assert_predicate bin/"mndp", :executable?
  end
end
