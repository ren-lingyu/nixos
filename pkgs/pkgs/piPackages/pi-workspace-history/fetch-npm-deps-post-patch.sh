@jq@ \
  'del(.devDependencies, .peerDependencies)' \
  package.json >package.json.new
mv package.json.new package.json

@jq@ '
  del(
    .packages[""].devDependencies,
    .packages[""].peerDependencies
  )
  | .packages |= with_entries(
      select(.key == "" or .value.dev != true)
    )
' package-lock.json >package-lock.json.new
mv package-lock.json.new package-lock.json
