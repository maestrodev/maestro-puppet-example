shared_context :maestro do

  let(:maestro_version) { '5.1.1' }
  let(:agent_version) { '2.6.0' }

  let(:repo) {{
    "url" => "https://repo.maestrodev.com/archiva/repository/all",
    "username" => "your_username",
    "password" => "CHANGEME"
  }}

end
