#include <string>

class TifWriter {

public:

  TifWriter();

  ~TifWriter();

  bool isTifFileOpen(void) const;

  void closeTifFile(void);

  // closes an existing file if one is open. returns true if open successful, false otherwise.
  // this opens the file, writes the initial TIFF header, and fseeks to the first IFD loc.
  bool openTifFile(const char *fname, const char *modestr = "wbn");

  // Call this before calling write*. It is assumed that there is a single sample per pixel.
  // The default of 8192 bytes/full strip is recommended by the TIFF spec (and eg libtiff).
  void configureImage(unsigned short imWidth, 
		      unsigned short imLength, 
		      unsigned short bytesPerPixel,
		      unsigned short numChannels, 		      
		      const char *imageDescription = NULL,
			  unsigned int targetBytesPerFullStrip = 8192);

  void writeFramesForAllChannels(const char *buf, unsigned int sz);

  static void writeTestFile(void);

private:

  void handleErr(const char *msg = NULL) const;

  // the following return values *per channel*, ie a "frame" represents an image in a single channel
  unsigned int getBytesPerRow(void) const { return fBytesPerPixel*fImageWidth; }
  unsigned int getBytesPerFullStrip(void) const { return fRowsPerStrip*getBytesPerRow(); }
  unsigned int getPixelsPerFrame(void) const { return fImageWidth*fImageLength; }
  unsigned int getBytesPerFrame(void) const { return getPixelsPerFrame()*fBytesPerPixel; }
  unsigned int getBitsPerFrame(void) const { return getBytesPerFrame()*8; }
  unsigned int getNumFullStripsPerFrame(void) const { return getBytesPerFrame()/getBytesPerFullStrip(); }
  unsigned int getStripsPerFrame(void) const { return (getBytesPerFrame()+getBytesPerFullStrip()-1)/getBytesPerFullStrip(); }

  void putDirectoryEntryShort(void *loc,
			      unsigned short tag,
			      unsigned short type,
			      unsigned int count,
			      unsigned short value);

  void putDirectoryEntryWithOffset(void *loc,
				   unsigned short tag,
				   unsigned short type,
				   unsigned int count,
				   unsigned int value);


  // Initialize IFD and SuppIFD state.
  void setupIFD(void);

  // Given the file offset of the start of a frame, update the offset values in the IFD/suppIFD.
  void updateOffsetsInIFDAndSuppIFD(unsigned int IFDFileOffset);

  // fwrite with errcheck
  void writeToFile(const void* buf, size_t sz, size_t cnt);
  
  // This writes the IFD and suppIFD and leaves the fileptr at the location for the imagedata for the frame.
  void writeIFD(void); 
  
  // Writes one frame/IFD to the current file. sz is redundant, it must equal the value returned by
  // getPixelsPerFrame(). the file ptr ends up at the loc for the next ifd.
  void writeSingleFrame(const char *buf, unsigned int sz);

  // Number of samples assumed to be one (grayscale image).
  unsigned short fImageWidth;
  unsigned short fImageLength;
  unsigned short fBytesPerPixel;  
  unsigned short fNumChannels;
  unsigned short fRowsPerStrip;
  std::string fImageDescription;

  // TIFF Types (directly from TIFF spec)
  enum TiffTypes {
    BYTETIFFTYPE = 1,
    ASCIITIFFTYPE,
    SHORTTIFFTYPE,
    LONGTIFFTYPE,
    RATIONALTIFFTYPE
  };

  // TIFF fields currently used by TifWriter
  enum FieldNames {
    ImageWidthField = 0,
    ImageLengthField,
    BitsPerSampleField,
    CompressionField,
    PhotometricInterpretationField,
    RowsPerStripField,
    ResolutionUnitField,
    OrientationField,
    SamplesPerPixelField,
    PlanarConfigurationField,
    XResolutionField,        // field val is offset
    YResolutionField,        // field val is offset
    ImageDescriptionField,   // field val is offset
    StripOffsetsField,       // field vals are offset; contents themselves are offsets
    StripByteCountsField,    // field vals are offset
    NUMFIELDS
  };

  static const unsigned int DIRENTRYSIZE = 12;
  static const unsigned int IFDSIZE = 2+TifWriter::NUMFIELDS*TifWriter::DIRENTRYSIZE+4;
  static const unsigned int VALUEOFFSETINFIELD = 8; // in a field, the value or offset-to-value starts at byte 8
  static const unsigned int FIRSTIFDFILEOFFSET = 104; // divisible by 8

  char fIFD[TifWriter::IFDSIZE];

  char *fSuppIFD;
  unsigned int fSuppIFDSize;
  struct { // offsets into the suppIFD for various field data
    unsigned int XResolution;
    unsigned int YResolution;
    unsigned int ImageDescription;
    unsigned int StripOffsets;
    unsigned int StripByteCounts;
  } fSuppIFDOffsets;

  bool fStripOffsetsAndStripByteCountsAreInIFD;

  // These are the offsets of the suppIFD, Image Data, and next (subsequent) IFD relative to byte 0 of
  // a Frame.
  struct {
    // unsigned int IFD; Conceptually, IFD is a field of this struct, but its value (offset) is always 0.
    unsigned int SuppIFD;
    unsigned int ImageData;
    unsigned int NextIFD;
  } fFrameOffsets;
    
  FILE *fTiffFH;
};
