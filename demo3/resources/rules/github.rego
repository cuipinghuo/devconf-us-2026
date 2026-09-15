package custom

import rego.v1

# METADATA
# title: Restrictions on GitHub origins
# description: >-
#   Verify that the source code originates from an allowed
#   GitHub organization, as specified in ruleData.
# custom:
#   short_name: git_origin_restriction
#
deny contains result if {
	allowed_origin := data.rule_data__configuration__.allowed_github_origins
	allowed_material_uri := sprintf("git+https://github.com/%s/", [allowed_origin])
	some attestation in input.attestations
	found := [material |
		some material in attestation.statement.predicate.materials
		startswith(material.uri, allowed_material_uri)
	]
	count(found) == 0
	result := {
		"code": "custom.git_origin_restriction",
		"msg": sprintf("Source code did not originate from the %s GitHub organization", [allowed_origin]),
	}
}
