defmodule ShareCircleWeb.Api.V1.FamilyJSON do
  alias ShareCircle.Families.Family

  def render(%Family{} = family) do
    %{
      id: family.id,
      name: family.name,
      slug: family.slug,
      timezone: family.timezone,
      member_limit: family.member_limit,
      inserted_at: family.inserted_at
    }
  end
end
