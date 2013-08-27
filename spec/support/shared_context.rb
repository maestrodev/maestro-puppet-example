shared_context :maestro do

  let(:maestro_version) { '4.17.2' }
  let(:agent_version) { '2.0.4' }

  let(:repo) {{
    "url" => "https://repo.maestrodev.com/archiva/repository/all",
    "username" => "your_username",
    "password" => "CHANGEME"
  }}

end
