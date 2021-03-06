using StanSample, MCMCChains, CSV

df = filter(row -> row[:age] >= 18, 
  CSV.read(joinpath(@__DIR__, "..", "..", "data", "Howell1.csv"), DataFrame))

# Define the Stan language model

m4_3s = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] height; // Predictor
 vector[N] weight; // Outcome
}

parameters {
 real alpha; // Intercept
 real beta; // Slope (regression coefficients)
 real < lower = 0 > sigma; // Error SD
}

model {
 height ~ normal(alpha + weight * beta , sigma);
}

generated quantities {
} 
";

# Define the Stanmodel and set the output format to :mcmcchains.

m_4_3s = SampleModel("m4.3s", m4_3s);

# Input data for cmdstan

m4_3_data = Dict("N" => size(df, 1), "height" => df[!, :height],
  "weight" => df[!, :weight]);

# Sample using cmdstan

rc = stan_sample(m_4_3s, data=m4_3_data)

# Describe the draws

if success(rc)
  chn = read_samples(m_4_3s; output_format=:mcmcchains)
  #chn = set_names(chn, Dict("mu" => "μ", "sigma" => "σ"))
  describe(chn)
end
