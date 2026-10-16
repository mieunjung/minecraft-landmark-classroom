# 공유 게시판 설정

이 사이트는 GitHub Pages에 올린 정적 사이트라서, 친구들과 게시물과 사진을 공유하려면 Supabase 프로젝트가 필요합니다. 아래 설정을 한 번 완료하면 사이트 방문자 누구나 게시판을 볼 수 있고, 익명으로 글을 올릴 수 있습니다.

## 1. Supabase 프로젝트 만들기

1. [Supabase](https://supabase.com/)에 로그인해 새 프로젝트를 만듭니다.
2. 프로젝트 화면의 **SQL Editor**에서 `supabase/schema.sql` 파일 내용을 실행합니다. 이 SQL은 공개 읽기, 익명 작성, 작성자 본인의 글 삭제, 시간당 최대 5개 게시물, 이미지 저장 규칙을 설정합니다.
3. **Authentication → Sign In / Providers**에서 **Allow anonymous sign-ins**를 켭니다.
4. **Project Settings → API**에서 Project URL과 **anon / publishable key**를 복사합니다. `service_role` 키는 절대 사용하거나 공개하지 마세요.

## 2. 사이트 설정하기

`supabase-config.js`에서 아래 두 값을 Supabase 프로젝트의 값으로 바꿉니다.

```js
window.LANDMARK_SUPABASE_CONFIG = {
  url: "https://YOUR-PROJECT.supabase.co",
  anonKey: "YOUR-PUBLIC-ANON-OR-PUBLISHABLE-KEY"
};
```

anon/publishable key는 브라우저에 공개되는 키입니다. 데이터 보호는 키를 숨기는 것이 아니라 SQL에 설정된 Row Level Security 정책으로 적용됩니다. **service_role 키는 절대로 이 파일에 넣지 마세요.**

## 3. GitHub Pages에 반영하고 확인하기

`index.html`, `supabase-config.js`, `supabase/schema.sql` 변경 사항을 GitHub 저장소의 `main` 브랜치에 올립니다. Pages 배포가 끝나면 사이트의 작품 게시판에 글과 이미지를 올린 뒤 다른 브라우저나 기기에서 같은 링크를 열어 게시물이 보이는지 확인합니다. 글은 최신 200개까지 표시됩니다.

공유 게시물은 작성한 브라우저에서만 삭제할 수 있습니다. 선생님은 Supabase Table Editor에서 부적절한 게시물을 관리할 수 있습니다. 게시물과 이미지가 공개되므로 학생들에게 본명, 학교, 얼굴, 연락처, 계정 정보 등 개인정보를 올리지 않도록 안내해 주세요.
