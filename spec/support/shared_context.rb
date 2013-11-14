shared_context :maestro do

  let(:maestro_version) { '4.18.1' }
  let(:agent_version) { '2.1.1' }

  let(:repo) {{
    "url" => "https://repo.maestrodev.com/archiva/repository/all",
    "username" => "your_username",
    "password" => "CHANGEME"
  }}

end
