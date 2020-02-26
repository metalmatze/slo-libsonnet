{
  local splitExpression(s) =
      local cleaned = std.strReplace(s, '~', '');
      local seperators = ["=", "!"];
      local results = [std.split(cleaned, sperator)
      for sperator in seperators];

      local match = std.filter(function(arr) std.length(arr) > 1, results);

      if std.length(match) == 1 then match[0] else error "unable to parse selector " + s,
  selectorsToLabels(labelset):: {
    [s[0]]: std.strReplace(s[1], '"', '')
    for s in [
      splitExpression(s)
      for s in labelset
    ]
  },
}
