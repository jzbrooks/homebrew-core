class Krakend < Formula
  desc "Ultra-High performance API Gateway built in Go"
  homepage "https://www.krakend.io/"
  url "https://github.com/devopsfaith/krakend-ce/archive/v2.0.0.tar.gz"
  sha256 "07ce9669881f13d9c3d1ae2c14de353461a44e7ef2d95a4cf1eb66d915fb59ed"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c80d48a2973cc064b78f21b493372a1487dea849cf377a734e9c0c6e35e68be2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "3ca8548f9dd4bd6630b6d8bf0df088dabdc90758698ef4dce5396a035092b251"
    sha256 cellar: :any_skip_relocation, monterey:       "925c77b04e62c4ca49dcfa6276abd3b6ec1f640c82ef4aa454a98a19f33aaad4"
    sha256 cellar: :any_skip_relocation, big_sur:        "e96ebd67d9b830b8c22915d6f358f939c843d5cfd4346075131956c5c4a1bd10"
    sha256 cellar: :any_skip_relocation, catalina:       "76c5215dddbc635a51078cb3d608f8125efd4f6700c17e30738d20ddaed5b123"
    sha256 cellar: :any_skip_relocation, mojave:         "13d26ae9ca567668659afe272939738bd56e612833c5ba316939f4e9ee19dd38"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c47ba0bf2430dc3b58e285f3360c70b90bb6e863a0554aadebf64321a1e3c058"
  end

  depends_on "go" => :build

  def install
    (buildpath/"src/github.com/devopsfaith/krakend-ce").install buildpath.children
    cd "src/github.com/devopsfaith/krakend-ce" do
      system "make", "build"
      bin.install "krakend"
      prefix.install_metafiles
    end
  end

  test do
    (testpath/"krakend_unsupported_version.json").write <<~EOS
      {
        "version": 2,
        "extra_config": {
          "github_com/devopsfaith/krakend-gologging": {
            "level": "WARNING",
            "prefix": "[KRAKEND]",
            "syslog": false,
            "stdout": true
          }
        }
      }
    EOS
    assert_match "unsupported version",
      shell_output("#{bin}/krakend check -c krakend_unsupported_version.json 2>&1", 1)

    (testpath/"krakend_bad_file.json").write <<~EOS
      {
        "version": 3,
        "bad": file
      }
    EOS
    assert_match "ERROR",
      shell_output("#{bin}/krakend check -c krakend_bad_file.json 2>&1", 1)

    (testpath/"krakend.json").write <<~EOS
      {
        "version": 3,
        "extra_config": {
          "telemetry/logging": {
            "level": "WARNING",
            "prefix": "[KRAKEND]",
            "syslog": false,
            "stdout": true
          }
        },
        "endpoints": [
          {
            "endpoint": "/test",
            "backend": [
              {
                "url_pattern": "/backend",
                "host": [
                  "http://some-host"
                ]
              }
            ]
          }
        ]
      }
    EOS
    assert_match "Syntax OK",
      shell_output("#{bin}/krakend check -c krakend.json 2>&1")
  end
end
