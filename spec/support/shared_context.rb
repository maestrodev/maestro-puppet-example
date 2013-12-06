shared_context :maestro do

  let(:maestro_version) { '4.19.3' }
  let(:agent_version) { '2.2.0' }

  let(:repo) {{
    "url" => "https://repo.maestrodev.com/archiva/repository/all",
    "username" => "your_username",
    "password" => "CHANGEME"
  }}

end
