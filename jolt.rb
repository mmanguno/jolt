class Jolt < Formula
  desc "JSON to JSON transformation library written in Java."
  homepage "https://github.com/bazaarvoice/jolt"
  url "https://github.com/bazaarvoice/jolt/archive/jolt-0.0.22.tar.gz"
  sha256 "ca1c379af14b746a524eeced309edfea25cf86f68ea4697271c9ad24b7834926"

  depends_on :java
  depends_on "maven" => :build

  def install
    # Maven clean the package and install all the jars
    system "mvn", "clean", "package"
    libexec.install %w[bin cli complete guice jolt-core json-utils parent]

    # Append the file names with SNAPSHOT so we don't break manual,
    # non-brew installs.
    jar_files = Dir.glob(libexec/"cli/target/*.jar")
    jar_files.each do |jar_file|
      File.rename(jar_file, jar_file.gsub(".jar", "-SNAPSHOT.jar"))
    end

    # Alter the executable to call the exact jar version. Using the wildcard
    # operator seems to break it.
    text = File.read(libexec/"bin/jolt")
    text_altered = text.gsub("jolt-cli-*", "jolt-cli-#{version}")
    File.open(libexec/"bin/jolt", "w") { |file| file.puts text_altered }

    # Finally, install the symlink into the bin
    bin.install_symlink libexec/"bin/jolt"
  end

  test do
    system "#{bin}/jolt sort <<< '{ \"a\" : \"1\", \"c\" : 3, \"b\" : 4 }'"
  end
end
