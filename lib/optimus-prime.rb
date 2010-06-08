class OptimusPrime
  
  class OptimusPrimeError < StandardError; end
  class TransformationMalfunction < OptimusPrimeError; end
  class TransformerNotFound < OptimusPrimeError; end
  
  attr_accessor :src
  attr_accessor :dst
  
  # OpenOffice runs in the background and JODConverter uses that to convert documents
  JODVER = '2.2.2'
  JODPTH = "../vendor/jodconverter-#{JODVER}"
  JODJAR = "#{JODPTH}/lib/jodconverter-cli-#{JODVER}.jar"
  
  @@content_types = {
    'csv'  => 'text/csv',
    'doc'  => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'htm'  => 'text/html',
    'html' => 'text/html',
    'odg'  => 'application/vnd.oasis.opendocument.graphics ',
    'odp'  => 'application/vnd.oasis.opendocument.presentation',
    'ods'  => 'application/vnd.oasis.opendocument.spreadsheet',
    'odt'  => 'application/vnd.oasis.opendocument.text',
    'pdf'  => 'application/pdf',
    'ppt'  => 'application/mspowerpoint',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'rtf'  => 'application/rtf',
    'svg'  => 'image/svg+xml',
    'swf'  => 'application/x-shockwave-flash',
    'sxc'  => 'application/vnd.sun.xml.calc',
    'sxi'  => 'application/vnd.sun.xml.impress',
    'sxw'  => 'application/vnd.sun.xml.writer',
    'txt'  => 'text/plain',
    'tsv'  => 'text/tsv',
    'wpd'  => 'application/x-wordperfect',
    'xls'  => 'application/msexcel'
  }
  
  @@open_office = {
    # Text Formats
    'odt'  => %w(pdf odt sxw rtf doc txt html),
    'sxw'  => %w(pdf odt sxw rtf doc txt html),
    'rtf'  => %w(pdf odt sxw rtf doc txt html),
    'doc'  => %w(pdf odt sxw rtf doc txt html),
    'docx' => %w(pdf odt sxw rtf doc txt html),
    'wpd'  => %w(pdf odt sxw rtf doc txt html),
    'txt'  => %w(pdf odt sxw rtf doc txt html),
    'html' => %w(pdf odt sxw rtf doc txt html),
    # Spreadsheet Formats
    'ods' => %w(pdf ods sxc xls csv tsv html),
    'sxc' => %w(pdf ods sxc xls csv tsv html),
    'xls' => %w(pdf ods sxc xls csv tsv html),
    'csv' => %w(pdf ods sxc xls csv tsv html),
    'tsv' => %w(pdf ods sxc xls csv tsv html),
    # Presentation Formats
    'odp' => %w(pdf swf odp sxi ppt html),
    'sxi' => %w(pdf swf odp sxi ppt html),
    'ppt' => %w(pdf swf odp sxi ppt html),
    # Drawing Formats
    'odg' => %w(svg swf)
  }
  
  @@pdf_text = {
    'pdf' => %w(txt)
  }
  
  
  def initialize(options={})
    @src = options[:src]
    @dst = options[:dst]
  end
  
  def transform
    # Runs the command to convert if needed
    system(cmd) unless File.exist?(dst)
    # Reads the file or throws exception that it's not there
    File.exist?(dst) ? dst : raise(TransformationMalfunction)
  end
  
  def self.transform(s,d)
    new(:src => s, :dst => d).transform
  end
  
  private
  
  def cmd
    # Replaces cmd_str placeholders with src and dst filenames
    cmd_str.gsub('SRC',src).gsub('DST',dst)
  end
  
  def cmd_str
    # Determine the command string that should be used based on source/destination extensions
    return "java -jar #{JODJAR} SRC DST" if transformable? @@open_office
    return "pdf_text SRC > DST"          if transformable? @@pdf_text
    raise TransformerNotFound, "#{ext(src)} => #{ext(dst)}"
  end
  
  def transformable?(transformer)
    return false unless transformer[ext(src)]
    transformer[ext(src)].include?(ext(dst))
  end

  def ext(m)
    # Returns extension from filename
    m.split('.')[-1]
  end
  
end # class OptimusPrime