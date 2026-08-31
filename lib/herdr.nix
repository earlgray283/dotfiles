{ pkgs }:

pkgs.runCommand "herdr-silent.mp3"
  {
    nativeBuildInputs = [ pkgs.ffmpeg-headless ];
  }
  ''
    ffmpeg -nostdin -loglevel error \
      -f lavfi -i anullsrc=r=8000:cl=mono -t 0.05 \
      -f mp3 -c:a libmp3lame "$out"
  ''
