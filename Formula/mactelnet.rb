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
    system "./autogen.sh"
    system "./configure", "--disable-silent-rules",
                          "--sysconfdir=#{etc}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mactelnet -v")
    assert_match "Usage", shell_output("#{bin}/mactelnet -h", 1)
    assert_match "Usage", shell_output("#{bin}/macping", 1)
    # mndp listens for MNDP broadcasts; just make sure it starts and can bind
    require "timeout"
    r, w = IO.pipe
    pid = spawn("#{bin}/mndp", out: w, err: w)
    begin
      Timeout.timeout(5) do
        assert_match "Searching for MikroTik routers", r.readline
      end
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
      w.close
      r.close
    end
  end
end
