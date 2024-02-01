# Ops Team Steampipe Report

Esse projeto tem como objetivo criar um dashboard customizado resumindo os principais pontos de melhoria nas contas AWS dos clientes.

### Install in MAC
```
brew install turbot/tap/steampipe

update

brew upgrade turbot/tap/steampipe

steampipe -v
```

### Install in Linux
```
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"

steampipe -v

install plugin
steampipe plugin install steampipe
```

### Install AWS plugin

```
steampipe plugin install aws
```

### Executar o dashboard
```
git clone git@github.com:opsteamhub/opsteam-steampipe-report.git

steampipe dashboard
```