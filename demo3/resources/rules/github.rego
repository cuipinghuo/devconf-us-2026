package custom

import rego.v1

import data.lib.rule_data

# METADATA
# title: Restrictions on GitHub origins
# description: >-
#   Verify that the source code originates from an allowed
#   GitHub organization, as specified in ruleData.
# custom:
#   short_name: git_origin_restriction
#
deny contains result if {
	some attestation in input.attestations
	github_materials := [material |
		some material in attestation.statement.predicate.materials
		startswith(material.uri, "git+https://github.com/")
	]
	allowed_origin := rule_data.get("allowed_github_org")
	allowed_material_uri := sprintf("git+https://github.com/%s/", [allowed_org])
	every material in github_materials {
		startswith(material.uri, allowed_material_uri)
	}
	result := {
		"code": "custom.git_origin_restriction",
		"msg": sprintf("Source code did not originate from the %s GitHub organization", [allowed_origin]),
	}
}
