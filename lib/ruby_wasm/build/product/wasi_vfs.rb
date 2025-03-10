require_relative "./product"

module RubyWasm
  class WasiVfsProduct < BuildProduct
    WASI_VFS_VERSION = "0.5.0"

    def initialize(build_dir)
      @build_dir = build_dir
      @need_fetch_lib = ENV["LIB_WASI_VFS_A"].nil?
      installed_cli_path =
        ENV["WASI_VFS_CLI"] || Toolchain.find_path("wasi-vfs")
      @need_fetch_cli = installed_cli_path.nil?
      @cli_path =
        installed_cli_path || File.join(cli_product_build_dir, "wasi-vfs")
    end

    def lib_product_build_dir
      File.join(
        @build_dir,
        "wasm32-unknown-wasi",
        "wasi-vfs-#{WASI_VFS_VERSION}"
      )
    end

    def lib_wasi_vfs_a
      ENV["LIB_WASI_VFS_A"] || File.join(lib_product_build_dir, "libwasi_vfs.a")
    end

    def cli_product_build_dir
      File.join(
        @build_dir,
        RbConfig::CONFIG["host"],
        "wasi-vfs-#{WASI_VFS_VERSION}"
      )
    end

    def cli_bin_path
      @cli_path
    end

    def name
      "wasi-vfs-#{WASI_VFS_VERSION}-#{RbConfig::CONFIG["host"]}"
    end

    def build(executor)
      return if !@need_fetch_lib || File.exist?(lib_wasi_vfs_a)
      require "tmpdir"
      lib_wasi_vfs_url =
        "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v#{WASI_VFS_VERSION}/libwasi_vfs-wasm32-unknown-unknown.zip"
      Dir.mktmpdir do |tmpdir|
        executor.system "curl",
                        "-L",
                        lib_wasi_vfs_url,
                        "-o",
                        "#{tmpdir}/libwasi_vfs.zip"
        executor.system "unzip", "#{tmpdir}/libwasi_vfs.zip", "-d", tmpdir
        executor.mkdir_p File.dirname(lib_wasi_vfs_a)
        executor.mv File.join(tmpdir, "libwasi_vfs.a"), lib_wasi_vfs_a
      end
    end

    def install_cli
      return if !@need_fetch_cli || File.exist?(cli_bin_path)
      FileUtils.mkdir_p cli_product_build_dir
      zipfile = File.join(cli_product_build_dir, "wasi-vfs-cli.zip")
      system "curl", "-L", "-o", zipfile, self.cli_download_url
      system "unzip", zipfile, "-d", cli_product_build_dir
    end

    def cli_download_url
      assets = [
        [/x86_64-linux/, "wasi-vfs-cli-x86_64-unknown-linux-gnu.zip"],
        [/x86_64-darwin/, "wasi-vfs-cli-x86_64-apple-darwin.zip"],
        [/arm64e?-darwin/, "wasi-vfs-cli-aarch64-apple-darwin.zip"]
      ]
      asset = assets.find { |os, _| os =~ RUBY_PLATFORM }&.at(1)
      if asset.nil?
        raise "unsupported platform for fetching wasi-vfs CLI: #{RUBY_PLATFORM}"
      end
      "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v#{WASI_VFS_VERSION}/#{asset}"
    end
  end
end
