# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# FASELUNAR

# https://faselua.fly.dev/


<!-- Esse código é um controlador Ruby on Rails chamado "MoonController". Ele possui uma ação chamada "index" que é responsável por fornecer informações sobre a fase da lua e as próximas fases, bem como a estação atual.

A ação "index" define três variáveis de instância: "@current_phase", "@next_phases" e "@current_season".

"@current_phase": Essa variável recebe o resultado da chamada ao método "current_moon_phase". Esse método obtém a data atual e calcula a fase atual da lua utilizando o método "calculate_moon_phase". O resultado é retornado como um hash com a chave ":phase" contendo o nome da fase.

"@next_phases": Essa variável recebe o resultado da chamada ao método "next_moon_phases(30)". Esse método recebe um parâmetro "count" que determina o número de fases futuras a serem exibidas. O método itera sobre as datas futuras e calcula a fase da lua para cada data utilizando o método "calculate_moon_phase". Os resultados são armazenados em um array como hashes contendo a data e o nome da fase. O array de fases é retornado.

"@current_season": Essa variável recebe o resultado da chamada ao método "current_season". Esse método determina a estação atual com base na data atual. Ele verifica se a data atual está dentro de um dos intervalos de datas para cada estação (verão, outono, inverno, primavera). O resultado é retornado como um hash com as chaves ":name" (nome da estação), ":start_date" (data de início da estação) e ":end_date" (data de término da estação).

Além dessas três principais funcionalidades, o código também possui outros métodos auxiliares:

"calculate_moon_phase": Calcula a fase da lua com base na data fornecida. Ele realiza cálculos usando o número juliano da data e a idade da lua em dias.

"phase_name": Retorna o nome da fase da lua com base no valor da fase.

"current_season": Determina a estação atual com base na data atual. Ele verifica se a data está dentro dos intervalos de datas definidos para cada estação e retorna um hash com o nome da estação e as datas de início e término.

No geral, esse código fornece informações sobre a fase da lua, próximas fases e estação atual com base na data atual. -->

<!-- 
Como são feito esses calculos?

Os cálculos são feitos usando o conceito de número juliano, que é um sistema de contar os dias a partir de uma origem fixa, no caso, a data de referência de 1 de janeiro de 4713 a.C. do calendário juliano. Esse sistema é usado para calcular o número de dias passados desde essa data até a data fornecida.

Vamos analisar o método calculate_moon_phase(date) para entender os cálculos específicos realizados:

def calculate_moon_phase(date)
  year = date.year
  month = date.month
  day = date.day

  # Cálculo do número juliano para a data
  a = (14 - month) / 12
  y = year + 4800 - a
  m = month + 12 * a - 3
  julian_day = day + ((153 * m + 2) / 5) + 365 * y + (y / 4) - (y / 100) + (y / 400) - 32045

  # Cálculo da idade da lua em dias
  base_date = Date.new(2000, 1, 6) # Data base para cálculo da idade da lua
  moon_age = (julian_day - base_date.jd) % 29.53

  # Cálculo da fase da lua
  phase = (moon_age / 29.53 * 8).to_i

  phase
end

Primeiro, o método extrai o ano, o mês e o dia da data fornecida.

Em seguida, é calculado o número juliano para a data fornecida. Isso é feito com base em uma fórmula que envolve os valores de year, month e day. O objetivo é obter um número que representa a quantidade de dias desde a origem fixa mencionada anteriormente.

Após o cálculo do número juliano, é necessário calcular a idade da lua em dias. Para isso, é definida uma data de referência chamada base_date, que é 6 de janeiro de 2000. A diferença entre o número juliano da data fornecida e o número juliano da base_date é calculada e, em seguida, é realizada uma operação de módulo por 29.53. O resultado é a idade da lua em dias.

Por fim, é calculada a fase da lua com base na idade da lua. A idade da lua é dividida por 29.53 (duração média de uma fase lunar) e multiplicada por 8. O resultado é arredondado para o número inteiro mais próximo, resultando em um valor de 0 a 7 que representa a fase da lua.

Os nomes das fases da lua são armazenados em um array chamado phase_names, e o valor calculado para a fase da lua é usado como índice para recuperar o nome correspondente dessa array.

Esses cálculos permitem determinar a fase da lua com base em uma data específica, usando conceitos astronômicos e um sistema de referência temporal. -->