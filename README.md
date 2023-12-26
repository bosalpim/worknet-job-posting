# 개요
해당 레포지토리는 케어파트너 서비스를 위한 배치 작업들을 작성하고 있습니다.

* 프레임웍: Ruby On Jets [https://rubyonjets.com/](https://rubyonjets.com/)
* 배포: AWS (CloudFront, S3, Lambda 등)

## 개발환경 설정
### RubyOnJets 설치
```bash
gem install jets
```
### 프로젝트 의존성 설치
```bash
bundle install
```

### 환경변수 설정
1. 1Password 내에 `worknet-job-posting` 환경변수 다운받기
2. `.env.local` 파일 생성 후 위에서 받은 환경변수 복사/붙여넣기
3. 로컬 개발 디비 호스트와 비밀번호를 `DB_HOST_DEV`, `DB_PASSWORD_DEV` 환경변수로 추가로 설정하기

### DB 마이그레이션
```shell
jest db:create db:migrate
```
## 실행하기

### 서버 실행
```bash
jets s
```

### 콘솔 실행
```bash
jets c
```

## 배포
### 개발
1. feature 브랜치를 만든다.
2. 작업 내용을 커밋한다.
3. staging 브랜치로 feature 브랜치를 머지한다.
4. 깃허브 워크플로우가 실행되며, AWS Lambda 스테이징 환경으로 배포한다.

### 운영
1. main 브랜치로 staging 브랜치를 머지한다.
2. 깃허브 워크플로우가 실행되며, AWS Lambda 프로덕션 환경으로 배포한다.