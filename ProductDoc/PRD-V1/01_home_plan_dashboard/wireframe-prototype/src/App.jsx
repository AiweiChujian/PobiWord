import { useMemo, useState } from "react";
import {
  ArrowsClockwise,
  Bell,
  BookOpenText,
  CalendarBlank,
  CardsThree,
  CaretDown,
  CaretRight,
  Check,
  Clock,
  FileText,
  Gear,
  Info,
  List,
  LockKey,
  Plus,
  ShoppingBag,
  Sparkle,
  SpeakerHigh,
  UserCircle,
  WifiHigh,
  BatteryFull,
  CellSignalFull,
  X,
} from "@phosphor-icons/react";

const SCREENS = [
  { id: "empty", label: "H-01 无学习计划" },
  { id: "new", label: "H-02 有计划无记录" },
  { id: "review", label: "H-03A 当前应复习" },
  { id: "learn", label: "H-03B 当前应学习" },
];

const initialParams = new URLSearchParams(window.location.search);
const requestedScreen = initialParams.get("state");
const initialScreen = SCREENS.some((item) => item.id === requestedScreen) ? requestedScreen : "review";
const initialOverlay = initialParams.get("overlay");

const PLAN_BY_SCREEN = {
  new: {
    title: "雅思核心词汇",
    source: "雅思核心词汇",
    learned: 0,
    total: 3000,
    remaining: 3000,
    mastered: 0,
    review: 0,
    date: "2026-12-18",
    batch: 30,
  },
  review: {
    title: "CET-4 核心词汇",
    source: "CET-4 核心词汇",
    learned: 360,
    total: 1200,
    remaining: 840,
    mastered: 180,
    review: 42,
    date: "2026-10-01",
    batch: 30,
  },
  learn: {
    title: "CET-4 核心词汇",
    source: "CET-4 核心词汇",
    learned: 360,
    total: 1200,
    remaining: 840,
    mastered: 180,
    review: 0,
    date: "2026-10-01",
    batch: 30,
  },
};

const formatNumber = (value) => new Intl.NumberFormat("zh-CN").format(value);

function StatusBar() {
  return (
    <div className="status-bar" aria-label="系统状态栏">
      <span>9:41</span>
      <div className="status-icons" aria-hidden="true">
        <CellSignalFull weight="fill" />
        <WifiHigh weight="bold" />
        <BatteryFull weight="fill" />
      </div>
    </div>
  );
}

function NavigationBar({ screen, plan, menuOpen, onMenu, onPlanMenu }) {
  const hasPlan = screen !== "empty";

  return (
    <header className="nav-bar">
      <button className="icon-button menu-button" onClick={onMenu} aria-label="打开个人与设置">
        <List size={28} weight="bold" />
      </button>
      {hasPlan ? (
        <button className="plan-title" onClick={onPlanMenu} aria-expanded={menuOpen}>
          <span>{plan.title}</span>
          <CaretDown size={18} weight="bold" className={menuOpen ? "caret-open" : ""} />
        </button>
      ) : (
        <div className="brand-title">Pobi</div>
      )}
      <span className="nav-spacer" aria-hidden="true" />
    </header>
  );
}

function PlanDashboard({ plan }) {
  const progress = plan.total > 0 ? plan.learned / plan.total : 0;
  const progressAngle = `${Math.min(360, Math.max(0, progress * 360))}deg`;

  return (
    <section className="plan-dashboard" aria-label="学习计划统计">
      <div className="progress-summary">
        <div
          className="progress-ring"
          style={{ "--progress-angle": progressAngle }}
          role="progressbar"
          aria-valuemin="0"
          aria-valuemax={plan.total}
          aria-valuenow={plan.learned}
          aria-label={`已加入学习 ${plan.learned}，共 ${plan.total} 个单词`}
        >
          <span className="progress-current">{formatNumber(plan.learned)}</span>
          <span className="progress-total">/{formatNumber(plan.total)}</span>
        </div>
        <span className="progress-caption">已加入学习</span>
      </div>

      <div className="dashboard-metrics">
        <div className="metric-card metric-remaining">
          <span className="metric-title"><BookOpenText size={13} weight="bold" />待学习</span>
          <strong>{formatNumber(plan.remaining)}</strong>
        </div>
        <div className="metric-card metric-mastered">
          <span className="metric-title"><Check size={13} weight="bold" />已掌握</span>
          <strong>{formatNumber(plan.mastered)}</strong>
        </div>
        <div className="metric-card metric-date">
          <span className="metric-title"><CalendarBlank size={13} weight="bold" />预计完成日期</span>
          <strong>{plan.date}</strong>
        </div>
      </div>
    </section>
  );
}

function ReviewSymbol() {
  return (
    <span className="entry-symbol review-symbol" aria-hidden="true">
      <CardsThree className="symbol-cards" size={44} weight="regular" />
      <ArrowsClockwise className="symbol-arrows" size={72} weight="regular" />
    </span>
  );
}

function LearningSymbol() {
  return (
    <span className="entry-symbol learning-symbol" aria-hidden="true">
      <BookOpenText className="symbol-book" size={48} weight="regular" />
      <Sparkle className="symbol-sparkle" size={22} weight="fill" />
    </span>
  );
}

function TaskEntry({ screen, plan, onNavigate }) {
  const isReview = screen === "review";
  const isFirstLearning = screen === "new";
  const count = isReview ? plan.review : plan.batch;
  const config = isReview
    ? {
        title: "本轮复习",
        helper: "先完成复习，再继续计划",
        primary: "开始复习",
        primaryTarget: "进入单词复习",
        secondary: "巩固学习",
        secondaryTarget: "进入巩固学习",
      }
    : {
        title: "本轮学习",
        helper: isFirstLearning ? "完成后，Pobi 会安排复习" : "复习已完成，继续推进计划",
        primary: "开始学习",
        primaryTarget: "进入新词批次选择",
        secondary: isFirstLearning ? null : "强化复习",
        secondaryTarget: "进入强化复习",
      };

  return (
    <section className={`entry-section ${isReview ? "review-entry" : "learning-entry"}`} aria-labelledby="entry-title">
      <div className="entry-content">
        <h1 id="entry-title">{config.title}</h1>
        <div className="entry-count"><strong>{count}</strong><span>个单词</span></div>
        <p>{config.helper}</p>
        <div className="entry-actions">
          <button className="entry-primary" onClick={() => onNavigate(config.primaryTarget)}>{config.primary}</button>
          {config.secondary && (
            <button className="entry-secondary" onClick={() => onNavigate(config.secondaryTarget)}>
              {config.secondary}<CaretRight size={18} weight="bold" />
            </button>
          )}
        </div>
      </div>
      {isReview ? <ReviewSymbol /> : <LearningSymbol />}
    </section>
  );
}

const ACTIVITY_LEVELS = [
  0, 1, 1, 3, 1, 2, 3, 1, 1, 2, 1, 0,
  1, 3, 2, 1, 1, 1, 3, 2, 1, 1, 3, 1,
  0, 1, 2, 3, 1, 1, 2, 1, 3, 1, 1, 2,
  1, 1, 1, 2, 1, 3, 1, 3, 2, 1, 1, 1,
  0, 1, 2, 3, 1, 3, 1, 2, 1, 1, 3, 0,
];

const ACTIVITY_LABELS = ["未学习", "仅完成复习", "完成学习和复习", "完成学习、复习与巩固"];

function ActivitySection() {
  return (
    <section className="activity-section" aria-label="近 60 天学习活动">
      <div className="activity-grid">
        {ACTIVITY_LEVELS.map((level, index) => (
          <span
            className={`activity-cell activity-level-${level}`}
            key={`${index}-${level}`}
            aria-label={`第 ${index + 1} 天：${ACTIVITY_LABELS[level]}`}
            title={ACTIVITY_LABELS[level]}
          />
        ))}
      </div>
      <span className="activity-caption">近 60 天</span>
    </section>
  );
}

function EmptyState({ onCreate }) {
  return (
    <section className="empty-state">
      <LearningSymbol />
      <h1>创建你的单词学习计划</h1>
      <p>选择或导入一本单词书，开启单词学习之旅。</p>
      <button className="primary-action" onClick={onCreate}><Plus size={20} weight="bold" /> 创建学习计划</button>
    </section>
  );
}

function PlanMenu({ onClose, onSelect, currentScreen }) {
  const currentTitle = currentScreen === "new" ? "雅思核心词汇" : "CET-4 核心词汇";
  const plans = [
    { screen: "review", title: "CET-4 核心词汇", meta: "已学习 360 / 1,200" },
    { screen: "new", title: "雅思核心词汇", meta: "尚未开始 · 共 3,000 词" },
  ];
  return (
    <>
      <button className="overlay menu-overlay" aria-label="关闭学习计划菜单" onClick={onClose} />
      <div className="plan-menu" role="dialog" aria-label="切换学习计划">
        <p>切换学习计划</p>
        {plans.map((item) => (
          <button key={item.screen} className="plan-menu-item" onClick={() => onSelect(item.screen)}>
            <span><strong>{item.title}</strong><small>{item.meta}</small></span>
            {currentTitle === item.title && <Check size={20} weight="bold" />}
          </button>
        ))}
        <button className="create-plan-row" onClick={() => onSelect("empty")}><Plus size={21} weight="bold" /> 创建新计划</button>
      </div>
    </>
  );
}

function Drawer({ onClose, onNavigate }) {
  const [reminder, setReminder] = useState(true);
  return (
    <>
      <button className="overlay drawer-overlay" aria-label="关闭个人与设置" onClick={onClose} />
      <aside className="drawer" aria-label="个人与设置">
        <div className="drawer-header">
          <div className="profile-row">
            <UserCircle size={52} weight="duotone" />
            <div><strong>Pobi 学习者</strong><span>保持自己的学习节奏</span></div>
          </div>
          <button className="icon-button close-button" onClick={onClose} aria-label="关闭个人与设置"><X size={24} weight="bold" /></button>
        </div>

        <button className="quota-card" onClick={() => onNavigate("进入学习额度购买") }>
          <span><small>剩余学习额度</small><strong>680 <em>词</em></strong></span>
          <span className="quota-link"><ShoppingBag size={18} weight="bold" /> 购买额度</span>
        </button>

        <section className="drawer-group">
          <h2>设置</h2>
          <div className="setting-row">
            <span className="setting-label"><Bell size={21} /><span><strong>每日学习提醒</strong><small>每天提醒一次</small></span></span>
            <button className={`switch ${reminder ? "switch-on" : ""}`} onClick={() => setReminder(!reminder)} aria-pressed={reminder} aria-label="每日学习提醒"><span /></button>
          </div>
          <button className="setting-row" disabled={!reminder}>
            <span className="setting-label"><Clock size={21} /><strong>提醒时间</strong></span>
            <span className="setting-value">20:30 <CaretRight size={16} /></span>
          </button>
          <button className="setting-row" onClick={() => onNavigate("进入声音与播放设置")}>
            <span className="setting-label"><SpeakerHigh size={21} /><strong>声音与播放</strong></span>
            <CaretRight size={17} />
          </button>
          <button className="setting-row" onClick={() => onNavigate("进入更多设置")}>
            <span className="setting-label"><Gear size={21} /><strong>更多设置</strong></span>
            <CaretRight size={17} />
          </button>
        </section>

        <section className="drawer-group about-group">
          <h2>关于</h2>
          <button className="setting-row"><span className="setting-label"><LockKey size={21} /><strong>隐私政策</strong></span><CaretRight size={17} /></button>
          <button className="setting-row"><span className="setting-label"><FileText size={21} /><strong>用户协议</strong></span><CaretRight size={17} /></button>
          <button className="setting-row"><span className="setting-label"><Info size={21} /><strong>关于 Pobi</strong></span><CaretRight size={17} /></button>
        </section>
        <p className="version">Version 1.0.0</p>
      </aside>
    </>
  );
}

function PrototypeControls({ screen, onChange }) {
  return (
    <nav className="prototype-controls" aria-label="线框图状态切换">
      <p>01 首页线框图</p>
      <h2>计划 · 入口 · Activity</h2>
      <span>选择画板状态</span>
      {SCREENS.map((item) => (
        <button key={item.id} className={screen === item.id ? "active" : ""} onClick={() => onChange(item.id)}>
          {item.label}
        </button>
      ))}
      <small>菜单与计划标题均可点击，查看对应浮层交互。</small>
    </nav>
  );
}

export function App() {
  const [screen, setScreen] = useState(initialScreen);
  const [drawerOpen, setDrawerOpen] = useState(initialOverlay === "drawer");
  const [planMenuOpen, setPlanMenuOpen] = useState(initialOverlay === "menu");
  const [toast, setToast] = useState("");
  const plan = useMemo(() => PLAN_BY_SCREEN[screen], [screen]);

  const showToast = (message) => {
    setToast(message);
    window.clearTimeout(showToast.timer);
    showToast.timer = window.setTimeout(() => setToast(""), 1800);
  };

  const changeScreen = (next) => {
    setScreen(next);
    setPlanMenuOpen(false);
    setDrawerOpen(false);
  };

  return (
    <main className="prototype-shell">
      <PrototypeControls screen={screen} onChange={changeScreen} />
      <div className="mobile-prototype" data-screen={screen}>
        <div className="app-surface">
          <StatusBar />
          <NavigationBar
            screen={screen}
            plan={plan}
            menuOpen={planMenuOpen}
            onMenu={() => { setDrawerOpen(true); setPlanMenuOpen(false); }}
            onPlanMenu={() => { setPlanMenuOpen(!planMenuOpen); setDrawerOpen(false); }}
          />

          <div className={`screen-scroll ${screen === "empty" ? "empty-scroll" : ""}`}>
            {screen === "empty" ? (
              <EmptyState onCreate={() => showToast("进入学习计划来源选择")} />
            ) : (
              <>
                <PlanDashboard plan={plan} />
                <TaskEntry screen={screen} plan={plan} onNavigate={showToast} />
                {screen !== "new" && <ActivitySection />}
              </>
            )}
          </div>

          {planMenuOpen && <PlanMenu currentScreen={screen} onClose={() => setPlanMenuOpen(false)} onSelect={changeScreen} />}
          {drawerOpen && <Drawer onClose={() => setDrawerOpen(false)} onNavigate={showToast} />}
          {toast && <div className="toast" role="status">{toast}</div>}
        </div>
      </div>
    </main>
  );
}
