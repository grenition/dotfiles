local M = {}

local manifest_stems = {
  "namespace",
  "workload",
  "workloads",
  "route",
  "network-policy",
  "network-policies",
  "gateway",
  "gateway-class",
  "envoy-proxy",
  "redirect",
  "issuer",
}

-- Maps Kubernetes- and Helm-related YAML files to canonical devicons filenames
-- that the neo-tree integration registers.
function M.icon_name(path, filename)
  if not path or path == "" or not filename or filename == "" then
    return nil
  end

  if filename:match("%.sops%.ya?ml$") then
    return "secret.sops.yaml"
  end

  if filename == "kustomization.yaml" then
    return "kustomization.yaml"
  end

  if filename:match("^values%.ya?ml$") or filename:match("%-values%.ya?ml$") or filename:match("^Chart%.ya?ml$") then
    return "helm.yaml"
  end

  local stem = filename:match("^(.+)%.ya?ml$")
  if not stem or not path:find("/k8s/", 1, true) then
    return nil
  end

  for _, manifest_stem in ipairs(manifest_stems) do
    if stem == manifest_stem then
      return "k8s-manifest.yaml"
    end
  end
  return nil
end

return M
