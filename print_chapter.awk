BEGIN {
  if (width > 60) {
    width = 60
  }
  printf(".ll %dn\n", width)
}

$0~lookup {
  print ".br"
  print ".hy 0"
  print ".ad c"
  print ".ft B"
  print title
  print ".br"
  print ".ft"
  if (flag == "p") {
    printf("Psalm %s\n", chapter)
  } else if (flag != "sc") {
    printf("Chapter %s\n", chapter)
  }
  print ".br"
  print ".hy 1"
  print ".ad n"
  keep_printing = 1
  found = 1
  next
} 

keep_printing && !/^%/ {
  if (match($0, /^[0-9]+:[0-9]+\./)) {
    a = substr($0, 1, RLENGTH)
    b = substr($0, RLENGTH + 2)
    match(a, /:/)
    a = substr(a, RSTART + 1)
    printf("\\fB~%s\\fP %s\n", a, b)
  } else if (match($0, /^.*\.\.\.+/)) {
    a = substr($0, 1, RLENGTH - 2)
    b = substr($0, RLENGTH + 2)
    printf("\\fI%s\\fP %s\n", a, b)
  } else {
    print 
  }
}

/^%/ {
  keep_printing = 0
}

END {
  # Footer
  print ".br"
  print ".ad c"
  if (found) {
    print ".ft B"
    if (flag == "g") {
      print "+ The Gospel of the Lord. +"
    } else if (flag != "p") {
      print "+ The word of the Lord. +"
    } else {
      print "+ Alleluia +"
    }
  } else {
    print ".br"
    print ".hy 0"
    print ".ft B"
    print title
    print ".ft"
    print ".br"
    print ""
    print ".ad n"
    printf("Chapter %s not found. ", chapter)
    print "If this is in error, please file a bug report."
  }
}
